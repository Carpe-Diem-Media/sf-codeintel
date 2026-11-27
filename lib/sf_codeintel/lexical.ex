defmodule SFCodeIntel.Lexical do
  @moduledoc false

  @module_token "[A-Z][A-Za-z0-9_]{0,31}(?:\\.[A-Z][A-Za-z0-9_]{0,31}){0,3}"
  @name_token "[a-z][a-z0-9_]{0,31}"
  @module_pattern Regex.compile!("\\A" <> @module_token <> "\\z")
  @name_pattern Regex.compile!("\\A" <> @name_token <> "\\z")
  @header Regex.compile!("\\A[ \\t]*defmodule[ \\t]+(" <> @module_token <> ")[ \\t]+do[ \\t]*\\z")
  @function Regex.compile!(
              "\\A[ \\t]*(defp?)[ \\t]+(" <>
                @name_token <> ")\\(([^()]*)\\)[ \\t]*,[ \\t]*do:[ \\t]*(.*)\\z"
            )
  @call Regex.compile!(
          "\\A((" <> @module_token <> ")\\.(" <> @name_token <> "))\\((.*)\\)[ \\t]*\\z"
        )
  @reserved ~w(after alias and case catch cond def defdelegate defexception defguard defguardp
               defimpl defmacro defmacrop defmodule defp defprotocol defstruct do else end false
               fn for if import in nil not or quote receive require rescue super true try unless
               unquote unquote_splicing use when with)
  @layout ~r/\A[ \t]*(?:\#.*)?\z/
  @ending ~r/\A[ \t]*end[ \t]*\z/
  @integer ~r/\A(?:0|[1-9][0-9]{0,8})\z/
  @string ~r/\A"([^"\\\p{Cc}\p{Zl}\p{Zp}]{0,256})"/u

  def module?(value) when is_binary(value) do
    Regex.match?(@module_pattern, value) and hd(:binary.split(value, ".")) != "Elixir"
  end

  def module?(_), do: false

  def name?(value) when is_binary(value) do
    Regex.match?(@name_pattern, value) and value not in @reserved
  end

  def name?(_), do: false

  def extract(bytes) do
    if String.valid?(bytes) do
      bytes
      |> lines(0, [])
      |> Enum.reduce_while({:header, nil, [], []}, &parse_line/2)
      |> finish()
    else
      :unsupported
    end
  end

  defp lines(bytes, offset, acc) do
    case :binary.split(bytes, "\n") do
      [last] -> Enum.reverse([{last, offset} | acc])
      [line, rest] -> lines(rest, offset + byte_size(line) + 1, [{strip_cr(line), offset} | acc])
    end
  end

  defp strip_cr(line) do
    size = byte_size(line)
    if size > 0 and :binary.last(line) == 13, do: binary_part(line, 0, size - 1), else: line
  end

  defp parse_line({line, offset}, state) do
    cond do
      :binary.match(line, "\r") != :nomatch -> {:halt, :unsupported}
      Regex.match?(@layout, line) -> {:cont, state}
      true -> parse_content(line, offset, state)
    end
  end

  defp parse_content(line, offset, {:header, nil, [], []}) do
    with [_, {start, length}] <- Regex.run(@header, line, return: :index),
         module = binary_part(line, start, length),
         true <- module?(module) do
      declaration = %{
        kind: "module",
        module: module,
        start_byte: offset + start,
        end_byte: offset + start + length
      }

      {:cont, {:body, module, [declaration], []}}
    else
      _ -> {:halt, :unsupported}
    end
  end

  defp parse_content(line, offset, {:body, module, declarations, calls}) do
    if Regex.match?(@ending, line) do
      {:cont, {:closed, module, declarations, calls}}
    else
      case function(line, offset, module) do
        {:ok, declaration, nil} ->
          {:cont, {:body, module, [declaration | declarations], calls}}

        {:ok, declaration, call} ->
          {:cont, {:body, module, [declaration | declarations], [call | calls]}}

        :unsupported ->
          {:halt, :unsupported}
      end
    end
  end

  defp parse_content(_line, _offset, _state), do: {:halt, :unsupported}

  defp finish({:closed, _, declarations, calls}) do
    {:ok, Enum.reverse(declarations), Enum.reverse(calls)}
  end

  defp finish(_), do: :unsupported

  defp function(line, offset, module) do
    with [_, visibility, {start, length}, parameters, {body_start, body_length}] <-
           Regex.run(@function, line, return: :index),
         name = binary_part(line, start, length),
         true <- name?(name),
         {:ok, params} <- parameters(extract_part(line, parameters)),
         body_bytes = binary_part(line, body_start, body_length),
         {:ok, call} <- body(body_bytes, params, offset + body_start) do
      declaration = %{
        kind: "function",
        module: module,
        function: name,
        arity: length(params),
        visibility: if(extract_part(line, visibility) == "def", do: "public", else: "private"),
        start_byte: offset + start,
        end_byte: offset + start + length
      }

      {:ok, declaration, call}
    else
      _ -> :unsupported
    end
  end

  defp extract_part(bytes, {start, length}), do: binary_part(bytes, start, length)

  defp parameters(bytes) do
    params =
      case trim_hspace(bytes) do
        "" -> []
        nonempty -> Enum.map(:binary.split(nonempty, ",", [:global]), &trim_hspace/1)
      end

    if length(params) <= 8 and Enum.all?(params, &name?/1) and Enum.uniq(params) == params do
      {:ok, params}
    else
      :unsupported
    end
  end

  defp body(bytes, params, offset) do
    case Regex.run(@call, bytes, return: :index) do
      [_, {0, length}, module, name, arguments] ->
        module = extract_part(bytes, module)
        name = extract_part(bytes, name)

        with true <- module?(module) and name?(name),
             {:ok, arity} <- arguments(trim_hspace(extract_part(bytes, arguments)), params) do
          {:ok,
           %{
             kind: "lexical_candidate",
             module: module,
             function: name,
             arity: arity,
             start_byte: offset,
             end_byte: offset + length
           }}
        end

      nil ->
        case value(bytes, params) do
          {:ok, ""} -> {:ok, nil}
          _ -> :unsupported
        end
    end
  end

  defp arguments("", _params), do: {:ok, 0}
  defp arguments(bytes, params), do: next_argument(bytes, params, 1)

  defp next_argument(_bytes, _params, count) when count > 8, do: :unsupported

  defp next_argument(bytes, params, count) do
    case value(bytes, params) do
      {:ok, ""} -> {:ok, count}
      {:ok, <<",", rest::binary>>} -> next_argument(trim_hspace(rest), params, count + 1)
      _ -> :unsupported
    end
  end

  defp value(<<"\"", _::binary>> = bytes, _params) do
    case Regex.run(@string, bytes) do
      [quoted, contents] when byte_size(contents) <= 256 ->
        if :binary.match(contents, <<35, 123>>) == :nomatch do
          start = byte_size(quoted)
          rest = binary_part(bytes, start, byte_size(bytes) - start)
          {:ok, trim_hspace(rest)}
        end

      _ ->
        :unsupported
    end
  end

  defp value(bytes, params) do
    case :binary.split(bytes, ",") do
      [token] -> bare_value(trim_hspace(token), "", params)
      [token, rest] -> bare_value(trim_hspace(token), "," <> rest, params)
    end
  end

  defp bare_value(token, rest, params) do
    if token in params or Regex.match?(@integer, token), do: {:ok, rest}, else: :unsupported
  end

  defp trim_hspace(bytes), do: Regex.replace(~r/\A[ \t]+|[ \t]+\z/, bytes, "")
end
