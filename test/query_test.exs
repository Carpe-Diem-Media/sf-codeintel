defmodule SFCodeIntel.QueryTest do
  use ExUnit.Case, async: true

  alias SFCodeIntel.{CLI, LocalSource, MCPStdio, Query, SourceAdapter}

  @sample "defmodule Demo.Sample do\n  def run(), do: 1\nend"
  @key %{"module" => "Demo.Sample", "function" => "run", "arity" => 0}
  @request %{
    "jsonrpc" => "2.0",
    "id" => 7,
    "method" => "tools/call",
    "params" => %{"name" => "definition", "arguments" => @key}
  }

  test "computes definition cardinality over the whole observed profile" do
    sample = %{"sample.ex" => @sample}
    partial = Map.put(sample, "unsupported.ex", "unsupported")

    assert %{status: :ok, uniqueness: "unique_in_profile"} = query(sample)
    assert %{status: :ok, uniqueness: "unknown", coverage: :partial} = query(partial)
    assert %{status: :ambiguous, items: [_, _]} = query(Map.put(partial, "duplicate.ex", @sample))
    assert %{status: :unsupported, items: []} = query(Map.delete(partial, "sample.ex"))
    assert %{status: :unresolved, items: []} = query(%{})
  end

  test "no authority or equality at admission prevents source access and response" do
    for binding <- [nil, %{valid_binding() | grant_id: ""}, valid_binding()] do
      assert :closed =
               exchange(binding, fn -> 200 end, fn _ -> flunk("capture on denial") end)
    end

    refute_received {:frame, _}
  end

  test "deadline equality at delivery suppresses the encoded frame" do
    ticks = :counters.new(1, [])
    :counters.put(ticks, 1, 199)

    capture = fn _ ->
      :counters.put(ticks, 1, 200)
      capture(%{"sample.ex" => @sample})
    end

    assert :closed = exchange(valid_binding(), fn -> :counters.get(ticks, 1) end, capture)
    refute_received {:frame, _}
  end

  test "delivery writes source evidence before the deadline" do
    capture = fn _ -> capture(%{"sample.ex" => @sample}) end
    assert {:ok, :ready} = exchange(valid_binding(), fn -> 199 end, capture)

    assert %{"status" => "ok", "items" => [%{"function" => "run"}]} = response()
  end

  test "changed second pass keeps both manifest IDs and drops source items from the wire" do
    first = capture(%{"sample.ex" => @sample})
    second = capture(%{"renamed.ex" => @sample})

    assert {:ok, :ready} = exchange(valid_binding(), fn -> 199 end, sequence(first, second))
    result = response()
    assert result["status"] == "changed_since_check"
    assert result["items"] == []
    assert result["freshness"]["state"] == "changed_since_check"
    assert result["freshness"]["comparison_slots"] == SourceAdapter.slots()
    assert result["freshness"]["first_manifest_sha256"] == elem(first, 1).manifest_sha256
    assert result["freshness"]["second_manifest_sha256"] == elem(second, 1).manifest_sha256
  end

  test "failed second pass keeps only the verified prefix and first manifest" do
    first = capture(%{"sample.ex" => @sample})
    second = {:error, :unavailable, ["caller.ex"], %{code: "read_failed", path: "duplicate.ex"}}

    assert {:ok, :ready} = exchange(valid_binding(), fn -> 199 end, sequence(first, second))
    result = response()
    assert result["status"] == "unavailable"
    assert result["coverage"] == "unavailable"
    assert result["items"] == []
    assert result["freshness"]["state"] == "unknown"
    assert result["freshness"]["checked_slots"] == ["caller.ex"]
    assert result["freshness"]["first_manifest_sha256"] == elem(first, 1).manifest_sha256
    refute Map.has_key?(result["freshness"], "second_manifest_sha256")
  end

  test "rejects an outside slot before capture" do
    args = %{
      "path" => "../sample.ex",
      "expected_sha256" => SourceAdapter.sha256(@sample)
    }

    assert %{status: :denied, items: []} =
             Query.run(valid_binding(), "check_source", args, fn _ ->
               flunk("outside slot caused capture")
             end)
  end

  test "search_text_matches_literal_bytes_in_path_and_offset_order" do
    slots = %{
      "caller.ex" => "é" <> <<255>> <> "a.* A.* a.*",
      "unsupported.ex" => "not Elixir! a.* aaa"
    }

    expected = [
      text_match(slots, "caller.ex", 3, 6),
      text_match(slots, "caller.ex", 11, 14),
      text_match(slots, "unsupported.ex", 12, 15)
    ]

    for _ <- 1..2 do
      assert_stable_search(slots, "a.*", :ok, expected)
    end

    assert_stable_search(slots, "aa", :ok, [text_match(slots, "unsupported.ex", 16, 18)])
  end

  test "search_text_reports_a_stable_miss_for_missing_and_present_slots" do
    for slots <- [%{}, %{"sample.ex" => @sample}] do
      assert_stable_search(slots, "missing", :unresolved, [])
    end
  end

  test "search_text_reports_an_ordered_prefix_only_after_hit_33" do
    slots = %{"caller.ex" => String.duplicate("hit ", 32)}
    expected = for offset <- 0..124//4, do: text_match(slots, "caller.ex", offset, offset + 3)

    assert_stable_search(slots, "hit", :ok, expected)

    more = Map.merge(slots, %{"duplicate.ex" => "hit", "unsupported.ex" => "hit"})

    on_scan = fn
      {:slot, path} -> send(self(), {:scanned_slot, path})
      {:match, _path} -> :ok
    end

    assert_stable_search(more, "hit", :ok, expected, true, on_scan: on_scan)
    assert_received {:scanned_slot, "caller.ex"}
    assert_received {:scanned_slot, "duplicate.ex"}
    refute_received {:scanned_slot, _}
  end

  test "search_text_rejects_invalid_arguments_without_capture" do
    assert "search_text" in Query.tools()

    for args <- [
          %{},
          %{"other" => "hit"},
          %{"query" => "hit", "extra" => true},
          %{"query" => 42},
          %{"query" => ""},
          %{"query" => String.duplicate("é", 64) <> "x"},
          %{"query" => "x\0y"},
          %{"query" => "x\ry"},
          %{"query" => "x\ny"}
        ] do
      result =
        Query.run(valid_binding(), "search_text", args, fn _ ->
          flunk("invalid search caused capture")
        end)

      assert result == search_result(:invalid_input, :unavailable, [], [%{code: "invalid_input"}])
    end

    needle = String.duplicate("é", 64)
    slots = %{"sample.ex" => needle}
    assert_stable_search(slots, needle, :ok, [text_match(slots, "sample.ex", 0, 128)])
  end

  test "search_text_suppresses_results_when_captures_cannot_be_verified" do
    first = capture(%{"caller.ex" => "hit"})
    changed = capture(%{"caller.ex" => "hit", "unsupported.ex" => "unrelated"})
    prefix = ["caller.ex", "duplicate.ex"]
    path = "renamed.ex"
    denied = {:error, :denied, prefix, %{code: "slot_type_or_identity", path: path}}
    unavailable = {:error, :unavailable, prefix, %{code: "slot_open_failed", path: path}}
    limit = {:error, :limit_exceeded, prefix, %{code: "capture_byte_limit", path: path}}
    failed = %{code: "capture_failed"}

    for {captures, first_pass} <- [
          {[denied], nil},
          {[unavailable], nil},
          {[limit], nil},
          {[first, unavailable], first}
        ] do
      {:error, status, checked, diagnostic} = List.last(captures)
      result = search("hit", captures, status)
      expected = search_result(status, :unavailable, [], [diagnostic])
      assert_search(result, expected, :unknown, checked, first_pass, nil)
    end

    cases = [
      {[:exit], :unavailable, failed, [], nil, nil},
      {[first, :exit], :unavailable, failed, [], first, nil},
      {[first, changed], :changed_since_check, %{code: "capture_changed"}, SourceAdapter.slots(),
       first, changed}
    ]

    for {captures, status, diagnostic, checked, first_pass, second_pass} <- cases do
      result = search("hit", captures, status)
      state = if status == :changed_since_check, do: :changed_since_check, else: :unknown

      assert_search(
        result,
        search_result(status, :unavailable, [], [diagnostic]),
        state,
        checked,
        first_pass,
        second_pass
      )
    end
  end

  for scenario <- [:before_scan, :during_scan, :after_revalidation, :after_manifest_change] do
    test "search_text_deadline_never_releases_prepared_items (#{scenario})" do
      assert_search_deadline(unquote(scenario))
    end
  end

  test "search text response fallback preserves a boundary string ID" do
    assert_search_fallback(:binary.copy(<<0>>, 64))
  end

  test "search text response fallback preserves a boundary integer ID" do
    assert_search_fallback(-9_999_999_999_999_999)
  end

  defp assert_search_deadline(scenario) do
    slots = %{"caller.ex" => "hit hit"}
    first = capture(slots)

    second =
      if scenario == :after_manifest_change,
        do: capture(Map.put(slots, "unsupported.ex", "changed")),
        else: first

    ticks = :counters.new(1, [])
    calls = :counters.new(1, [])
    expire_on_next_check = :counters.new(1, [])
    expire = fn -> :counters.put(ticks, 1, 2_000) end

    capture = fn _ ->
      :counters.add(calls, 1, 1)

      case :counters.get(calls, 1) do
        1 ->
          if scenario == :before_scan, do: expire.()
          first

        2 ->
          if scenario == :after_revalidation, do: expire.()
          if scenario == :after_manifest_change, do: :counters.put(expire_on_next_check, 1, 1)
          second
      end
    end

    on_scan = fn event ->
      send(self(), {:search_scan, event})
      if scenario == :during_scan and event == {:match, "caller.ex"}, do: expire.()
    end

    clock = fn ->
      now = :counters.get(ticks, 1)
      # Let the post-capture check pass so expiry overrides the prepared change at delivery.
      if :counters.get(expire_on_next_check, 1) == 1, do: expire.()
      now
    end

    result =
      Query.run_search(valid_binding(), %{"query" => "hit"}, capture,
        clock: clock,
        on_scan: on_scan
      )

    completed_second =
      case scenario do
        :before_scan ->
          refute_received {:search_scan, _}
          assert :counters.get(calls, 1) == 1
          nil

        :during_scan ->
          assert_received {:search_scan, {:slot, "caller.ex"}}
          assert_received {:search_scan, {:match, "caller.ex"}}
          refute_received {:search_scan, _}
          assert :counters.get(calls, 1) == 1
          nil

        _after_second_capture ->
          assert :counters.get(calls, 1) == 2
          second
      end

    expected = search_result(:limit_exceeded, :unavailable, [], [%{code: "tool_deadline"}])
    assert_search(result, expected, :unknown, SourceAdapter.slots(), first, completed_second)
  end

  defp assert_search_fallback(id) do
    args = %{"query" => "hit"}
    pass = capture(%{"sample.ex" => "hit"})
    prepared = Query.run(valid_binding(), "search_text", args, fn _ -> pass end)
    assert %{status: :ok, items: [item]} = prepared
    oversized = %{prepared | items: List.duplicate(item, 400)}
    assert IO.iodata_length(:json.encode(oversized)) > 32_768

    request = %{
      @request
      | "id" => id,
        "params" => %{"name" => "search_text", "arguments" => args}
    }

    input = request |> :json.encode() |> IO.iodata_to_binary()
    assert byte_size(input) < 16_384

    assert {:ok, :ready} =
             MCPStdio.exchange(input, :ready, valid_binding(),
               clock: fn -> 199 end,
               capture: fn _ -> flunk("fallback test should use the prepared result") end,
               search_result: fn _, ^args -> oversized end,
               write: fn frame ->
                 send(self(), {:frame, IO.iodata_to_binary(frame)})
                 :ok
               end
             )

    assert_received {:frame, frame}
    assert byte_size(frame) <= 32_768
    assert :binary.matches(frame, "\n") == [{byte_size(frame) - 1, 1}]

    expected =
      prepared
      |> Map.merge(%{
        status: :limit_exceeded,
        coverage: :unavailable,
        truncated: true,
        items: [],
        diagnostics: [%{code: "response_byte_limit"}]
      })
      |> :json.encode()
      |> IO.iodata_to_binary()
      |> :json.decode()

    decoded = :json.decode(frame)
    assert decoded["id"] === id
    assert %{"result" => %{"content" => [%{"text" => text}]}} = decoded

    assert decoded == %{
             "jsonrpc" => "2.0",
             "id" => id,
             "result" => %{
               "structuredContent" => expected,
               "content" => [%{"type" => "text", "text" => text}],
               "isError" => true
             }
           }

    assert :json.decode(text) == expected
  end

  defp assert_stable_search(slots, needle, status, items, truncated \\ false, opts \\ []) do
    pass = capture(slots)
    expected = %{search_result(status, :complete_for_profile, items, []) | truncated: truncated}
    result = search(needle, [pass, pass], status, opts)
    assert_search(result, expected, :matched_at_check, SourceAdapter.slots(), pass, pass)
  end

  defp search(needle, captures, status, opts \\ []) do
    count = :counters.new(1, [])

    capture = fn _ ->
      index = :counters.get(count, 1)
      :counters.add(count, 1, 1)

      case Enum.fetch!(captures, index) do
        :exit -> exit(:scripted_capture_failure)
        outcome -> outcome
      end
    end

    args = %{"query" => needle}

    result =
      case opts do
        [] -> Query.run(valid_binding(), "search_text", args, capture)
        [_ | _] -> Query.run_search(valid_binding(), args, capture, opts)
      end

    assert %{status: ^status} = result
    assert :counters.get(count, 1) == length(captures)
    result
  end

  defp assert_search(result, expected, state, checked, first, second) do
    assert %{checked_at: checked_at} = result
    assert {:ok, _, 0} = DateTime.from_iso8601(checked_at)
    assert String.ends_with?(checked_at, "Z")

    freshness =
      %{
        state: state,
        checked_at: checked_at,
        method: "double_capture_slot_sha256",
        comparison_slots: SourceAdapter.slots(),
        checked_slots: checked
      }
      |> with_manifest(:first_manifest_sha256, first)
      |> with_manifest(:second_manifest_sha256, second)

    expected =
      expected
      |> Map.merge(%{
        binding_id: valid_binding().id,
        backend_version: "local_source_v1",
        profile_version: "synthetic_text_search_v1",
        checked_at: checked_at,
        freshness: freshness
      })
      |> with_manifest(:manifest_sha256, first)

    assert result == expected
  end

  defp with_manifest(map, _key, nil), do: map
  defp with_manifest(map, key, {:ok, capture}), do: Map.put(map, key, capture.manifest_sha256)

  defp search_result(status, coverage, items, diagnostics) do
    %{
      schema_version: 1,
      status: status,
      coverage: coverage,
      truncated: false,
      items: items,
      diagnostics: diagnostics
    }
  end

  defp text_match(slots, path, start, stop) do
    %{
      kind: "text_match",
      path: path,
      sha256: SourceAdapter.sha256(Map.fetch!(slots, path)),
      start_byte: start,
      end_byte: stop
    }
  end

  defp query(slots) do
    Query.run(valid_binding(), "definition", @key, fn _ -> capture(slots) end)
  end

  defp capture(slots) do
    LocalSource.capture_slots(fn path ->
      case Map.fetch(slots, path) do
        {:ok, bytes} -> {:ok, bytes}
        :error -> :missing
      end
    end)
  end

  defp sequence(first, second) do
    count = :counters.new(1, [])

    fn _ ->
      :counters.add(count, 1, 1)
      if :counters.get(count, 1) == 1, do: first, else: second
    end
  end

  defp exchange(binding, clock, capture) do
    MCPStdio.exchange(:json.encode(@request) |> IO.iodata_to_binary(), :ready, binding,
      clock: clock,
      capture: capture,
      write: fn frame ->
        send(self(), {:frame, IO.iodata_to_binary(frame)})
        :ok
      end
    )
  end

  defp response do
    assert_received {:frame, frame}
    decoded = :json.decode(frame)
    assert decoded["id"] == 7

    assert %{
             "content" => [%{"type" => "text", "text" => text}],
             "structuredContent" => data
           } = decoded["result"]

    assert :json.decode(text) == data
    data
  end

  defp valid_binding do
    %CLI.Binding{
      root: "/synthetic",
      device: 1,
      inode: 2,
      uid: 1000,
      id: "session-test",
      grant_id: "test-grant",
      start_ms: 100,
      deadline_ms: 200,
      grant_deadline_ms: 200
    }
  end
end
