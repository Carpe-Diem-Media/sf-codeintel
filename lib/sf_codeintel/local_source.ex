defmodule SFCodeIntel.LocalSource do
  @moduledoc false
  @behaviour SFCodeIntel.SourceAdapter

  import Bitwise
  require Record

  alias SFCodeIntel.SourceAdapter

  Record.defrecordp(:file_info, Record.extract(:file_info, from_lib: "kernel/include/file.hrl"))

  @slot_limit 16_384
  @pass_limit 81_920

  def validate_root(%{root: root, device: device, inode: inode, uid: uid}) do
    with true <- root != "/" and root == Path.expand(root),
         true <- Path.type(root) == :absolute,
         :ok <- validate_ancestors(Path.split(root), "/", uid),
         {:ok, stat} <- File.lstat(root, time: :posix),
         true <-
           stat.type == :directory and stat.uid == uid and (stat.mode &&& 0o7777) == 0o700 and
             stat.major_device == device and stat.inode == inode do
      :ok
    else
      _ -> {:error, :denied, "root_binding_mismatch"}
    end
  end

  @impl true
  def capture(binding) do
    capture_slots(fn slot ->
      with :ok <- validate_root(binding) do
        capture_slot(binding, slot)
      end
    end)
  end

  @doc false
  def capture_slots(read_slot) do
    SourceAdapter.slots()
    |> Enum.reduce_while({%{}, [], 0}, fn path, {slots, checked, size} ->
      case read_slot.(path) do
        :missing ->
          {:cont, {Map.put(slots, path, :missing), [path | checked], size}}

        {:ok, bytes}
        when byte_size(bytes) <= @slot_limit and size + byte_size(bytes) <= @pass_limit ->
          slot = %{bytes: bytes, sha256: SourceAdapter.sha256(bytes)}
          {:cont, {Map.put(slots, path, slot), [path | checked], size + byte_size(bytes)}}

        {:ok, _bytes} ->
          {:halt, failure(:limit_exceeded, checked, path, "capture_byte_limit")}

        {:error, status, code} ->
          {:halt, failure(status, checked, path, code)}
      end
    end)
    |> finish_capture()
  end

  defp failure(status, checked, path, code) do
    {:error, status, Enum.reverse(checked), %{path: path, code: code}}
  end

  defp finish_capture({slots, checked, _size}) do
    checked = Enum.reverse(checked)

    manifest =
      Enum.map(checked, fn path ->
        case slots[path] do
          :missing ->
            [<<byte_size(path)::16>>, path, <<0>>]

          %{bytes: bytes, sha256: sha256} ->
            [<<byte_size(path)::16>>, path, <<1, byte_size(bytes)::32>>, sha256]
        end
      end)

    {:ok,
     %{
       slots: slots,
       checked_slots: checked,
       manifest_sha256: SourceAdapter.sha256(["sf-codeintel-manifest-v1\0", manifest])
     }}
  end

  defp finish_capture(error), do: error

  defp validate_ancestors(["/" | rest], "/", uid) do
    with :ok <- safe_directory("/", uid), do: validate_ancestors(rest, "/", uid)
  end

  defp validate_ancestors([_root_name], _parent, _uid), do: :ok

  defp validate_ancestors([part | rest], parent, uid) do
    path = Path.join(parent, part)
    with :ok <- safe_directory(path, uid), do: validate_ancestors(rest, path, uid)
  end

  defp safe_directory(path, uid) do
    case File.lstat(path, time: :posix) do
      {:ok, %{type: :directory, uid: owner, mode: mode}}
      when owner in [0, uid] and (mode &&& 0o022) == 0 ->
        :ok

      _ ->
        :error
    end
  end

  defp capture_slot(binding, slot) do
    path = Path.join(binding.root, slot)

    case File.lstat(path, time: :posix) do
      {:ok, stat} -> open_slot(path, stat, binding.device)
      {:error, :enoent} -> :missing
      {:error, _} -> {:error, :unavailable, "slot_stat_failed"}
    end
  end

  defp open_slot(path, stat, device) do
    cond do
      stat.type != :regular or stat.links != 1 or stat.major_device != device ->
        {:error, :denied, "slot_type_or_identity"}

      stat.size > @slot_limit ->
        {:error, :limit_exceeded, "slot_byte_limit"}

      true ->
        case :file.open(path, [:read, :binary, :raw]) do
          {:ok, fd} ->
            try do
              read_slot(fd, stat)
            after
              :file.close(fd)
            end

          {:error, _} ->
            {:error, :unavailable, "slot_open_failed"}
        end
    end
  end

  defp read_slot(fd, stat) do
    with :ok <- descriptor_matches(fd, stat),
         {:ok, bytes} <- read_bytes(fd),
         true <- byte_size(bytes) == stat.size,
         :ok <- descriptor_matches(fd, stat) do
      {:ok, bytes}
    else
      false -> {:error, :unavailable, "slot_size_changed"}
      error -> error
    end
  end

  defp descriptor_matches(fd, stat) do
    case :file.read_file_info(fd, [{:time, :posix}]) do
      {:ok, info} ->
        cond do
          file_info(info, :type) != :regular or
              file_info(info, :links) != 1 or
              file_info(info, :major_device) != stat.major_device or
              file_info(info, :inode) != stat.inode ->
            {:error, :denied, "descriptor_identity_mismatch"}

          file_info(info, :size) != stat.size or file_info(info, :mtime) != stat.mtime or
              file_info(info, :ctime) != stat.ctime ->
            {:error, :unavailable, "slot_metadata_changed"}

          true ->
            :ok
        end

      {:error, _} ->
        {:error, :unavailable, "descriptor_stat_failed"}
    end
  end

  defp read_bytes(fd) do
    case :file.read(fd, @slot_limit + 1) do
      :eof -> {:ok, ""}
      {:ok, bytes} when byte_size(bytes) <= @slot_limit -> {:ok, bytes}
      {:ok, _} -> {:error, :limit_exceeded, "slot_byte_limit"}
      {:error, _} -> {:error, :unavailable, "slot_read_failed"}
    end
  end
end
