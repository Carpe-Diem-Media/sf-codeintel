defmodule SFCodeIntel.Query do
  @moduledoc false

  alias SFCodeIntel.{Lexical, LocalSource, SourceAdapter}

  @profile "synthetic_lexical_v1"
  @search_profile "synthetic_text_search_v1"
  @backend "local_source_v1"
  @tools ~w(discover definition references read_source check_source search_text)
  @key_fields ~w(arity function module)
  @read_fields ~w(end_byte path start_byte)
  @digest ~r/\A[[:xdigit:]]{64}\z/
  @item_limit 32
  @range_limit 4096
  @request_limit_ms 2000

  def tools, do: @tools
  def profile, do: @profile

  def run(binding, tool, args, capture \\ &LocalSource.capture/1)

  def run(binding, "search_text", args, capture), do: run_search(binding, args, capture, [])

  def run(binding, tool, args, capture) do
    case validate(tool, args) do
      :ok -> observe(binding, tool, args, capture)
      status -> result(status, :unavailable, [], [%{code: Atom.to_string(status)}])
    end
  end

  @doc false
  def run_search(binding, %{"query" => needle} = args, capture, opts)
      when map_size(args) == 1 and is_binary(needle) and byte_size(needle) in 1..128 do
    if String.valid?(needle) and :binary.match(needle, [<<0>>, "\r", "\n"]) == :nomatch do
      clock = Keyword.get(opts, :clock, &System.monotonic_time(:millisecond))
      on_scan = Keyword.get(opts, :on_scan, fn _ -> :ok end)
      observe_search(binding, needle, capture, clock, on_scan)
    else
      invalid_search()
    end
  end

  def run_search(_binding, _args, _capture, _opts), do: invalid_search()

  defp invalid_search do
    result(:invalid_input, :unavailable, [], [%{code: "invalid_input"}])
  end

  defp observe_search(binding, needle, capture, clock, on_scan) do
    deadline = clock.() + @request_limit_ms

    case timed_capture(binding, capture, deadline, clock) do
      {:ok, first} ->
        prepared = prepare_search(first, needle, on_scan)
        second = timed_capture(binding, capture, deadline, clock)
        revalidate_search(binding, first, second, prepared)

      {:error, status, checked, diagnostic} ->
        search_failure(binding, status, checked, diagnostic, nil)
    end
  end

  defp prepare_search(first, needle, on_scan) do
    pattern = :binary.compile_pattern(needle)

    {items, count} =
      Enum.reduce_while(SourceAdapter.slots(), {[], 0}, fn path, acc ->
        on_scan.({:slot, path})

        case first.slots[path] do
          :missing ->
            {:cont, acc}

          slot ->
            scan_slot(slot, path, pattern, 0, acc, on_scan)
        end
      end)

    status = if count == 0, do: :unresolved, else: :ok
    prepared = result(status, :complete_for_profile, Enum.reverse(items), [])
    %{prepared | truncated: count > @item_limit}
  end

  defp scan_slot(%{bytes: bytes}, _path, _pattern, offset, acc, _on_scan)
       when offset == byte_size(bytes),
       do: {:cont, acc}

  defp scan_slot(slot, path, pattern, offset, {items, count} = acc, on_scan) do
    scope = {offset, byte_size(slot.bytes) - offset}
    match = :binary.match(slot.bytes, pattern, scope: scope)
    on_scan.({:match, path})

    case match do
      :nomatch ->
        {:cont, acc}

      {_start, _length} when count == @item_limit ->
        {:halt, {items, count + 1}}

      {start, length} ->
        stop = start + length

        item = %{
          kind: "text_match",
          path: path,
          sha256: slot.sha256,
          start_byte: start,
          end_byte: stop
        }

        scan_slot(slot, path, pattern, stop, {[item | items], count + 1}, on_scan)
    end
  end

  defp revalidate_search(binding, first, {:ok, second}, prepared) do
    {response, state} =
      if first.manifest_sha256 == second.manifest_sha256 do
        {prepared, :matched_at_check}
      else
        changed = result(:changed_since_check, :unavailable, [], [%{code: "capture_changed"}])
        {changed, :changed_since_check}
      end

    search_evidence(response, binding, state, second.checked_slots, first, second)
  end

  defp revalidate_search(binding, first, {:error, status, checked, diagnostic}, _prepared) do
    search_failure(binding, status, checked, diagnostic, first)
  end

  defp search_failure(binding, status, checked, diagnostic, first) do
    status
    |> result(:unavailable, [], [diagnostic])
    |> search_evidence(binding, :unknown, checked, first, nil)
  end

  defp search_evidence(response, binding, state, checked, first, second) do
    response
    |> evidence(binding, state, checked, first, second, nil)
    |> Map.replace!(:profile_version, @search_profile)
  end

  defp validate("discover", args) when args == %{}, do: :ok

  defp validate(tool, %{"module" => module, "function" => name, "arity" => arity} = args)
       when tool in ["definition", "references"] do
    if exact_keys?(args, @key_fields) and Lexical.module?(module) and Lexical.name?(name) and
         is_integer(arity) and arity in 0..8 do
      :ok
    else
      :invalid_input
    end
  end

  defp validate(
         "read_source",
         %{"path" => path, "start_byte" => start, "end_byte" => stop} = args
       )
       when is_binary(path) and is_integer(start) and is_integer(stop) do
    fields =
      if Map.has_key?(args, "expected_sha256"),
        do: ["expected_sha256" | @read_fields],
        else: @read_fields

    if exact_keys?(args, fields) and
         (fields == @read_fields or valid_digest?(args["expected_sha256"])) do
      validate_slot(path)
    else
      :invalid_input
    end
  end

  defp validate("check_source", %{"path" => path, "expected_sha256" => digest} = args)
       when is_binary(path) do
    if map_size(args) == 2 and valid_digest?(digest) do
      validate_slot(path)
    else
      :invalid_input
    end
  end

  defp validate(_, _), do: :invalid_input

  defp exact_keys?(args, keys) do
    map_size(args) == length(keys) and Enum.all?(keys, &Map.has_key?(args, &1))
  end

  defp valid_digest?(value), do: is_binary(value) and Regex.match?(@digest, value)
  defp validate_slot(path), do: if(path in SourceAdapter.slots(), do: :ok, else: :denied)

  defp observe(binding, tool, args, capture) do
    deadline = System.monotonic_time(:millisecond) + @request_limit_ms

    case timed_capture(binding, capture, deadline) do
      {:ok, first} ->
        analysis = analyze(first)
        prepared = prepare(tool, args, first, analysis)
        second = timed_capture(binding, capture, deadline)
        revalidate(binding, args, second, first, prepared, deadline)

      {:error, status, checked, diagnostic} ->
        failed(binding, status, checked, diagnostic, nil)
    end
  end

  defp timed_capture(binding, capture, deadline, clock \\ &System.monotonic_time(:millisecond)) do
    remaining = deadline - clock.()

    if remaining > 0 do
      task = Task.async(fn -> capture.(binding) end)

      case Task.yield(task, remaining) || Task.shutdown(task, :brutal_kill) do
        {:ok, result} -> result
        {:exit, _} -> {:error, :unavailable, [], %{code: "capture_failed"}}
        nil -> {:error, :limit_exceeded, [], %{code: "tool_deadline"}}
      end
    else
      {:error, :limit_exceeded, [], %{code: "tool_deadline"}}
    end
  end

  defp revalidate(binding, args, {:ok, second}, first, prepared, deadline) do
    equal? = first.manifest_sha256 == second.manifest_sha256
    guarded? = equal? and Map.has_key?(args, "expected_sha256")

    response =
      cond do
        not equal? ->
          result(:changed_since_check, :unavailable, [], [%{code: "capture_changed"}])

        guarded? and not digest_matches?(first, args) ->
          result(:changed_since_check, prepared.coverage, [], prepared.diagnostics)

        true ->
          prepared
      end

    state =
      if response.status == :changed_since_check,
        do: :changed_since_check,
        else: :matched_at_check

    response =
      if System.monotonic_time(:millisecond) < deadline do
        response
      else
        result(:limit_exceeded, response.coverage, [], [%{code: "tool_deadline"}])
      end

    guarded_path = if guarded?, do: args["path"]
    evidence(response, binding, state, second.checked_slots, first, second, guarded_path)
  end

  defp revalidate(
         binding,
         _args,
         {:error, status, checked, diagnostic},
         first,
         _prepared,
         _deadline
       ) do
    failed(binding, status, checked, diagnostic, first)
  end

  defp failed(binding, status, checked, diagnostic, first) do
    result(status, :unavailable, [], [diagnostic])
    |> evidence(binding, :unknown, checked, first, nil, nil)
  end

  defp evidence(response, binding, state, checked, first, second, guarded_path) do
    checked_at = DateTime.utc_now() |> DateTime.to_iso8601()

    freshness = %{
      state: state,
      checked_at: checked_at,
      checked_slots: checked,
      comparison_slots: if(guarded_path, do: [guarded_path], else: SourceAdapter.slots()),
      method:
        if(guarded_path,
          do: "double_capture_slot_sha256_and_expected_digest",
          else: "double_capture_slot_sha256"
        )
    }

    freshness =
      freshness
      |> put_manifest(:first_manifest_sha256, first)
      |> put_manifest(:second_manifest_sha256, second)

    response
    |> Map.merge(%{
      binding_id: binding.id,
      backend_version: @backend,
      profile_version: @profile,
      checked_at: checked_at,
      freshness: freshness
    })
    |> put_manifest(:manifest_sha256, first)
  end

  defp put_manifest(map, _key, nil), do: map

  defp put_manifest(map, key, %{manifest_sha256: digest}), do: Map.put(map, key, digest)

  defp digest_matches?(capture, %{"path" => path, "expected_sha256" => digest}) do
    case capture.slots[path] do
      %{sha256: observed} -> observed == String.downcase(digest)
      :missing -> false
    end
  end

  defp analyze(capture) do
    {declarations, calls, diagnostics} =
      Enum.reduce(SourceAdapter.slots(), {[], [], []}, fn path, acc ->
        analyze_slot(path, capture.slots[path], acc)
      end)

    %{
      declarations: declarations |> Enum.reverse() |> List.flatten(),
      calls: calls |> Enum.reverse() |> List.flatten(),
      diagnostics: Enum.reverse(diagnostics),
      coverage: if(diagnostics == [], do: :complete_for_profile, else: :partial)
    }
  end

  defp analyze_slot(_path, :missing, acc), do: acc

  defp analyze_slot(path, %{bytes: bytes, sha256: digest}, {declarations, calls, diagnostics}) do
    case Lexical.extract(bytes) do
      {:ok, file_declarations, file_calls} ->
        attach = &Map.merge(&1, %{path: path, sha256: digest})

        {[Enum.map(file_declarations, attach) | declarations],
         [Enum.map(file_calls, attach) | calls], diagnostics}

      :unsupported ->
        {declarations, calls, [%{code: "unsupported_source", path: path} | diagnostics]}
    end
  end

  defp prepare("discover", _args, _capture, analysis) do
    lexical_result(analysis, analysis.declarations)
  end

  defp prepare("definition", args, _capture, analysis) do
    case Enum.filter(analysis.declarations, &same_key?(&1, args)) do
      [] ->
        lexical_result(analysis, [])

      [item] ->
        uniqueness = if analysis.coverage == :partial, do: "unknown", else: "unique_in_profile"
        analysis |> lexical_result([item]) |> Map.put(:uniqueness, uniqueness)

      items ->
        result(:ambiguous, analysis.coverage, items, analysis.diagnostics)
    end
  end

  defp prepare("references", args, _capture, analysis) do
    lexical_result(analysis, Enum.filter(analysis.calls, &same_key?(&1, args)))
  end

  defp prepare("read_source", args, capture, analysis) do
    %{"path" => path, "start_byte" => start, "end_byte" => stop} = args

    {status, items} =
      case capture.slots[path] do
        :missing ->
          {:unresolved, []}

        %{bytes: bytes, sha256: digest} ->
          cond do
            start < 0 or start >= stop or stop > byte_size(bytes) ->
              {:invalid_input, []}

            stop - start > @range_limit ->
              {:limit_exceeded, []}

            true ->
              excerpt = bytes |> binary_part(start, stop - start) |> Base.encode64()

              item = %{
                path: path,
                sha256: digest,
                start_byte: start,
                end_byte: stop,
                base64: excerpt
              }

              {:ok, [item]}
          end
      end

    result(status, analysis.coverage, items, analysis.diagnostics)
  end

  defp prepare("check_source", _args, _capture, analysis) do
    result(:ok, analysis.coverage, [], analysis.diagnostics)
  end

  defp same_key?(item, args) do
    Map.get(item, :function) == args["function"] and item.module == args["module"] and
      item.arity == args["arity"]
  end

  defp lexical_result(analysis, items) do
    status =
      case {items, analysis.coverage} do
        {[], :partial} -> :unsupported
        {[], :complete_for_profile} -> :unresolved
        {[_ | _], _} -> :ok
      end

    result(status, analysis.coverage, items, analysis.diagnostics)
  end

  defp result(status, coverage, items, diagnostics) do
    {kept, remaining} = Enum.split(items, @item_limit)

    %{
      schema_version: 1,
      status: status,
      coverage: coverage,
      truncated: remaining != [],
      items: kept,
      diagnostics: diagnostics
    }
  end
end
