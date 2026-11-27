defmodule SFCodeIntel.LocalSourceTest do
  use ExUnit.Case, async: true

  alias SFCodeIntel.{LocalSource, SourceAdapter}

  test "accounts for missing slots and hashes every present slot" do
    assert {:ok, first} =
             LocalSource.capture_slots(fn
               "sample.ex" -> {:ok, "one"}
               _ -> :missing
             end)

    assert first.checked_slots == SourceAdapter.slots()
    assert first.slots["caller.ex"] == :missing
    assert first.slots["sample.ex"].sha256 == SourceAdapter.sha256("one")

    assert {:ok, second} =
             LocalSource.capture_slots(fn
               "sample.ex" -> {:ok, "two"}
               _ -> :missing
             end)

    refute first.manifest_sha256 == second.manifest_sha256

    assert {:ok, renamed} =
             LocalSource.capture_slots(fn
               "renamed.ex" -> {:ok, "one"}
               _ -> :missing
             end)

    refute first.manifest_sha256 == renamed.manifest_sha256
  end

  test "failure reports only earlier verified slots and stops the pass" do
    assert {:error, :unavailable, ["caller.ex"], %{path: "duplicate.ex"}} =
             LocalSource.capture_slots(fn
               "caller.ex" -> :missing
               "duplicate.ex" -> {:error, :unavailable, "read_failed"}
               slot -> flunk("unexpected slot: #{slot}")
             end)
  end
end
