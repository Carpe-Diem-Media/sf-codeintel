defmodule SFCodeIntel.CLI do
  @moduledoc false

  alias SFCodeIntel.{LocalSource, MCPStdio, Query}

  defmodule Binding do
    @moduledoc false
    @enforce_keys [
      :root,
      :device,
      :inode,
      :uid,
      :id,
      :grant_id,
      :start_ms,
      :deadline_ms,
      :grant_deadline_ms
    ]
    defstruct @enforce_keys
  end

  @max_session_ms 300_000
  @label ~r/\A[A-Za-z0-9_-]{1,64}\z/

  def main(["--root", root, mode]) when mode in ["doctor", "mcp"] do
    case launch(root, mode) do
      0 -> :ok
      code -> System.halt(code)
    end
  end

  def main(_args) do
    diagnostic("invalid_launch_arguments")
    System.halt(2)
  end

  defp launch(root, mode) do
    with {:ok, binding} <- load_binding(root, System.get_env("SFCI_LAUNCH_BINDING")),
         true <- authorized?(binding, &clock/0),
         :ok <- LocalSource.validate_root(binding) do
      run(mode, binding)
    else
      _ ->
        diagnostic("launch_denied")
        2
    end
  end

  defp run("mcp", binding), do: MCPStdio.run(binding)

  defp run("doctor", binding) do
    if authorized?(binding, &clock/0) do
      result = Query.run(binding, "discover", %{})

      line =
        result
        |> Map.take([:schema_version, :coverage, :diagnostics])
        |> Map.merge(%{profile_version: Query.profile(), status: doctor_status(result.status)})
        |> :json.encode()

      case deliver(binding, &clock/0, [line, "\n"], &:file.write(:standard_io, &1)) do
        :ok -> doctor_exit(result.status)
        :closed -> 2
        {:error, _} -> 1
      end
    else
      diagnostic("authority_expired")
      2
    end
  end

  defp doctor_status(status) when status in [:ok, :unsupported, :unresolved], do: :ok
  defp doctor_status(status), do: status

  defp doctor_exit(status) when status in [:ok, :unsupported, :unresolved], do: 0
  defp doctor_exit(:denied), do: 2
  defp doctor_exit(_), do: 1

  defp load_binding(root, raw) when is_binary(raw) and byte_size(raw) <= 8192 do
    with {:ok, value} <- MCPStdio.decode(raw),
         %{
           "root" => ^root,
           "device" => device,
           "inode" => inode,
           "uid" => uid,
           "binding_id" => id,
           "grant_id" => grant_id,
           "launch_monotonic_ms" => start_ms,
           "deadline_monotonic_ms" => deadline_ms,
           "grant_deadline_monotonic_ms" => grant_deadline_ms
         } <- value,
         true <- map_size(value) == 9 do
      {:ok,
       %Binding{
         root: root,
         device: device,
         inode: inode,
         uid: uid,
         id: id,
         grant_id: grant_id,
         start_ms: start_ms,
         deadline_ms: deadline_ms,
         grant_deadline_ms: grant_deadline_ms
       }}
    else
      _ -> :error
    end
  end

  defp load_binding(_root, _raw), do: :error

  def authorized?(%Binding{} = binding, clock) do
    with true <- valid_binding?(binding),
         now when is_integer(now) <- clock.() do
      now >= binding.start_ms and now < binding.deadline_ms
    else
      _ -> false
    end
  end

  def authorized?(_binding, _clock), do: false

  defp valid_binding?(binding) do
    numbers = [
      binding.device,
      binding.inode,
      binding.uid,
      binding.start_ms,
      binding.deadline_ms,
      binding.grant_deadline_ms
    ]

    is_binary(binding.root) and Path.type(binding.root) == :absolute and
      valid_label?(binding.id) and valid_label?(binding.grant_id) and
      Enum.all?(numbers, &(is_integer(&1) and &1 >= 0)) and
      binding.inode > 0 and binding.deadline_ms > binding.start_ms and
      binding.deadline_ms <= min(binding.start_ms + @max_session_ms, binding.grant_deadline_ms)
  end

  defp valid_label?(value), do: is_binary(value) and Regex.match?(@label, value)

  # Linux displays boot time with centisecond precision. Round up for each
  # child guard so that display rounding cannot extend the launcher deadline.
  def clock do
    with {:ok, uptime} <- File.read("/proc/uptime"),
         [_, seconds, centiseconds] <- Regex.run(~r/\A([0-9]{1,12})\.([0-9]{2}) /, uptime) do
      String.to_integer(seconds) * 1000 + String.to_integer(centiseconds) * 10 + 10
    else
      _ -> :unavailable
    end
  end

  def deliver(binding, clock, frame, write) do
    if authorized?(binding, clock) do
      write.(frame)
    else
      diagnostic("authority_expired_or_invalid")
      :closed
    end
  end

  def diagnostic(code), do: IO.puts(:stderr, code)
end
