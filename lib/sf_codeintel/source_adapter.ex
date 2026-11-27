defmodule SFCodeIntel.SourceAdapter do
  @moduledoc """
  Capture contract for the five approved synthetic source slots.

  A complete pass retains immutable bytes and their manifest. A failed pass
  reports the checked prefix and a safe diagnostic without returning bytes.
  """

  @type slot :: %{bytes: binary(), sha256: binary()} | :missing
  @type capture :: %{
          slots: %{binary() => slot()},
          checked_slots: [binary()],
          manifest_sha256: binary()
        }
  @type failure :: :unavailable | :denied | :limit_exceeded

  @callback capture(map()) ::
              {:ok, capture()} | {:error, failure(), [binary()], map()}

  def slots, do: ~w(caller.ex duplicate.ex renamed.ex sample.ex unsupported.ex)

  def sha256(bytes), do: Base.encode16(:crypto.hash(:sha256, bytes), case: :lower)
end
