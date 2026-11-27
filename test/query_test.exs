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
    for binding <- [nil, %{binding() | grant_id: ""}, binding()] do
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

    assert :closed = exchange(binding(), fn -> :counters.get(ticks, 1) end, capture)
    refute_received {:frame, _}
  end

  test "delivery writes source evidence before the deadline" do
    capture = fn _ -> capture(%{"sample.ex" => @sample}) end
    assert {:ok, :ready} = exchange(binding(), fn -> 199 end, capture)

    assert %{"status" => "ok", "items" => [%{"function" => "run"}]} = response()
  end

  test "changed second pass keeps both manifest IDs and drops source items from the wire" do
    first = capture(%{"sample.ex" => @sample})
    second = capture(%{"renamed.ex" => @sample})

    assert {:ok, :ready} = exchange(binding(), fn -> 199 end, sequence(first, second))
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

    assert {:ok, :ready} = exchange(binding(), fn -> 199 end, sequence(first, second))
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
             Query.run(binding(), "check_source", args, fn _ ->
               flunk("outside slot caused capture")
             end)
  end

  defp query(slots) do
    Query.run(binding(), "definition", @key, fn _ -> capture(slots) end)
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

  defp binding do
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
