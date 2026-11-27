defmodule SFCodeIntel.MCPStdio do
  @moduledoc false

  alias SFCodeIntel.{CLI, LocalSource, Query, SourceAdapter}

  @protocol "2025-06-18"
  @frame_limit 16_384
  @response_limit 32_768
  @session_frames 100

  @key_properties %{
    module: %{
      type: "string",
      pattern: "^(?!Elixir(?:\\.|$))[A-Z][A-Za-z0-9_]{0,31}(\\.[A-Z][A-Za-z0-9_]{0,31}){0,3}$"
    },
    function: %{type: "string", pattern: "^[a-z][a-z0-9_]{0,31}$"},
    arity: %{type: "integer", minimum: 0, maximum: 8}
  }
  @path %{type: "string", enum: SourceAdapter.slots()}
  @digest %{type: "string", pattern: "^[A-Fa-f0-9]{64}$"}
  @byte %{type: "integer", minimum: 0, maximum: 16_384}

  def run(binding) do
    case :io.setopts(:standard_io, [:binary, {:encoding, :latin1}]) do
      :ok -> loop(binding, :awaiting_initialize, @session_frames)
      _ -> terminal("stdio_setup_failed")
    end
  end

  defp loop(_binding, _state, 0), do: 0

  defp loop(binding, state, remaining) do
    if CLI.authorized?(binding, &CLI.clock/0) do
      case read_frame([], 0) do
        {:ok, frame} ->
          case exchange(frame, state, binding, []) do
            {:ok, next} -> loop(binding, next, remaining - 1)
            :closed -> terminal("session_closed")
            {:error, _} -> terminal("write_failed")
          end

        :eof ->
          0

        {:error, code} ->
          terminal(code)
      end
    else
      terminal("authority_expired_or_invalid")
    end
  end

  defp terminal(code) do
    CLI.diagnostic(code)
    1
  end

  defp read_frame(acc, size) do
    case :file.read(:standard_io, 1) do
      {:ok, <<10>>} -> {:ok, acc |> Enum.reverse() |> :erlang.list_to_binary() |> strip_cr()}
      {:ok, _} when size == @frame_limit -> {:error, "frame_too_large"}
      {:ok, <<byte>>} -> read_frame([byte | acc], size + 1)
      :eof when size == 0 -> :eof
      :eof -> {:error, "unfinished_frame"}
      _ -> {:error, "read_failed"}
    end
  end

  defp strip_cr(frame) do
    size = byte_size(frame)
    if size > 0 and :binary.last(frame) == 13, do: binary_part(frame, 0, size - 1), else: frame
  end

  @doc false
  def exchange(frame, state, binding, opts) do
    clock = Keyword.get(opts, :clock, &CLI.clock/0)
    capture = Keyword.get(opts, :capture, &LocalSource.capture/1)
    write = Keyword.get(opts, :write, &:file.write(:standard_io, &1))

    if CLI.authorized?(binding, clock) do
      case decode(frame) do
        {:ok, decoded} -> dispatch(decoded, state, binding, clock, capture, write)
        :error -> send_reply(error(:null, -32_700, "Parse error"), state, binding, clock, write)
      end
    else
      :closed
    end
  end

  @doc false
  def decode(frame) do
    with true <- String.valid?(frame),
         :nomatch <- :binary.match(frame, ["\r", "\n"]),
         {value, 0, rest} <- :json.decode(frame, 0, decoders()),
         true <- Regex.match?(~r/\A[ \t]*\z/, rest) do
      {:ok, value}
    else
      _ -> :error
    end
  rescue
    _error -> :error
  end

  defp decoders do
    %{
      integer: &decode_integer/1,
      object_start: &start_container(&1, %{}),
      object_push: &object_push/3,
      object_finish: fn {_depth, values}, old -> {values, old} end,
      array_start: &start_container(&1, []),
      array_push: fn value, {depth, values} -> {depth, [value | values]} end,
      array_finish: fn {_depth, values}, old -> {Enum.reverse(values), old} end
    }
  end

  defp decode_integer(token) do
    digits = if :binary.first(token) == ?-, do: byte_size(token) - 1, else: byte_size(token)
    if digits > 16, do: raise(ArgumentError), else: String.to_integer(token)
  end

  defp depth({depth, _values}), do: depth
  defp depth(depth), do: depth

  defp start_container(acc, values) do
    depth = depth(acc) + 1
    if depth > 16, do: raise(ArgumentError), else: {depth, values}
  end

  defp object_push(key, value, {depth, object}) do
    if Map.has_key?(object, key) do
      raise ArgumentError
    else
      {depth, Map.put(object, key, value)}
    end
  end

  defp dispatch(message, state, binding, clock, capture, write) do
    case envelope(message) do
      {:notification, method, params} ->
        {:ok, notify(method, params, state)}

      {:request, id, method, params} ->
        {reply, next} = request(method, params, state, id, binding, capture)
        send_reply(reply, next, binding, clock, write)

      :invalid ->
        send_reply(error(:null, -32_600, "Invalid request"), state, binding, clock, write)
    end
  end

  defp envelope(%{"jsonrpc" => "2.0", "method" => method} = message) when is_binary(method) do
    allowed = ["jsonrpc", "method", "params", "id"]
    params = Map.get(message, "params", %{})

    cond do
      Enum.any?(Map.keys(message), &(&1 not in allowed)) ->
        :invalid

      not Map.has_key?(message, "id") ->
        {:notification, method, params}

      valid_id?(message["id"]) ->
        {:request, message["id"], method, params}

      true ->
        :invalid
    end
  end

  defp envelope(_), do: :invalid

  defp valid_id?(id), do: is_integer(id) or (is_binary(id) and byte_size(id) <= 64)

  defp notify("notifications/initialized", params, :awaiting_initialized) do
    if params_match?(params, []), do: :ready, else: :awaiting_initialized
  end

  defp notify(_method, _params, state), do: state

  defp request("ping", params, state, id, _binding, _capture) do
    if params_match?(params, []), do: {success(id, %{}), state}, else: {bad_params(id), state}
  end

  defp request("initialize", params, :awaiting_initialize, id, _binding, _capture) do
    if initialize_params?(params) do
      response = %{
        protocolVersion: @protocol,
        capabilities: %{tools: %{listChanged: false}},
        serverInfo: %{name: "sf-codeintel", version: "0.1.0"}
      }

      {success(id, response), :awaiting_initialized}
    else
      {bad_params(id), :awaiting_initialize}
    end
  end

  defp request(method, _params, state, id, _binding, _capture)
       when method == "initialize" or
              (method in ["tools/list", "tools/call"] and state != :ready) or
              method == "notifications/initialized" do
    {error(id, -32_600, "Invalid lifecycle state"), state}
  end

  defp request("tools/list", params, :ready, id, _binding, _capture) do
    if params_match?(params, ["cursor"]) and not Map.has_key?(params, "cursor") do
      {success(id, %{tools: tools()}), :ready}
    else
      {bad_params(id), :ready}
    end
  end

  defp request("tools/call", %{"name" => name} = params, :ready, id, binding, capture) do
    args = Map.get(params, "arguments", %{})

    if params_match?(params, ["name", "arguments"]) and name in Query.tools() and is_map(args) do
      result = Query.run(binding, name, args, capture)
      {{:tool, id, result}, :ready}
    else
      {bad_params(id), :ready}
    end
  end

  defp request("tools/call", _params, :ready, id, _binding, _capture) do
    {bad_params(id), :ready}
  end

  defp request(_method, _params, state, id, _binding, _capture) do
    {error(id, -32_601, "Method not found"), state}
  end

  defp initialize_params?(
         %{"protocolVersion" => version, "capabilities" => caps, "clientInfo" => client} = params
       ) do
    fields = ["protocolVersion", "capabilities", "clientInfo"]

    is_binary(version) and params_match?(params, fields) and
      client_info?(client) and capabilities?(caps)
  end

  defp initialize_params?(_), do: false

  defp client_info?(%{"name" => name, "version" => version} = info) do
    is_binary(name) and is_binary(version) and is_binary(Map.get(info, "title", "")) and
      Enum.all?(Map.keys(info), &(&1 in ["name", "version", "title"]))
  end

  defp client_info?(_), do: false

  defp capabilities?(capabilities) when is_map(capabilities) do
    Enum.all?(capabilities, fn
      {"roots", roots} ->
        is_map(roots) and Map.keys(roots) in [[], ["listChanged"]] and
          is_boolean(Map.get(roots, "listChanged", false))

      {"experimental", experiments} ->
        is_map(experiments) and Enum.all?(experiments, fn {_key, value} -> is_map(value) end)

      {key, value} when key in ["sampling", "elicitation"] ->
        is_map(value)

      {_key, _value} ->
        true
    end)
  end

  defp capabilities?(_), do: false

  defp params_match?(params, fields) when is_map(params) do
    Enum.all?(Map.keys(params), &(&1 in ["_meta" | fields])) and
      is_map(Map.get(params, "_meta", %{}))
  end

  defp params_match?(_params, _fields), do: false

  defp send_reply(reply, state, binding, clock, write) do
    frame = encode_reply(reply)

    case CLI.deliver(binding, clock, frame, write) do
      :ok -> {:ok, state}
      other -> other
    end
  end

  defp encode_reply({:tool, id, result}) do
    frame = tool_frame(id, result)

    if IO.iodata_length(frame) <= @response_limit do
      frame
    else
      limited =
        result
        |> Map.drop([:uniqueness])
        |> Map.merge(%{
          status: :limit_exceeded,
          items: [],
          truncated: true,
          diagnostics: [%{code: "response_byte_limit"}]
        })

      tool_frame(id, limited)
    end
  end

  defp encode_reply(reply), do: [:json.encode(reply), "\n"]

  defp tool_frame(id, result) do
    text = result |> :json.encode() |> IO.iodata_to_binary()

    tool = %{
      structuredContent: result,
      content: [%{type: "text", text: text}],
      isError: result.status in [:denied, :invalid_input, :limit_exceeded, :unavailable]
    }

    encode_reply(success(id, tool))
  end

  defp success(id, result), do: %{jsonrpc: "2.0", id: id, result: result}

  defp error(id, code, message) do
    %{jsonrpc: "2.0", id: id, error: %{code: code, message: message}}
  end

  defp bad_params(id), do: error(id, -32_602, "Invalid params")

  defp tools do
    key_fields = [:module, :function, :arity]
    read_properties = %{path: @path, start_byte: @byte, end_byte: @byte, expected_sha256: @digest}
    check_properties = %{path: @path, expected_sha256: @digest}

    [
      tool("discover", "List module and function declarations.", %{}, []),
      tool("definition", "Find declarations with an exact key.", @key_properties, key_fields),
      tool("references", "Find qualified lexical call candidates.", @key_properties, key_fields),
      tool("read_source", "Read a bounded source byte range.", read_properties, [
        :path,
        :start_byte,
        :end_byte
      ]),
      tool("check_source", "Compare the full-file SHA-256 at an approved slot.", check_properties, [
        :path,
        :expected_sha256
      ])
    ]
  end

  defp tool(name, description, properties, required) do
    %{
      name: name,
      description: description,
      inputSchema: %{
        type: "object",
        additionalProperties: false,
        properties: properties,
        required: required
      }
    }
  end
end
