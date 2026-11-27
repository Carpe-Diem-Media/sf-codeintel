defmodule SFCodeIntel.LexicalTest do
  use ExUnit.Case, async: true

  alias SFCodeIntel.Lexical

  test "retains the original byte positions across CRLF and UTF-8" do
    bytes =
      "# café\r\ndefmodule Demo.Call do\r\n  def run(x), do: Demo.Sample.echo(\"a,b\", x)\r\nend"

    assert {:ok, [module, function], [call]} = Lexical.extract(bytes)
    assert %{kind: "module", module: "Demo.Call"} = module
    assert %{kind: "function", function: "run", arity: 1} = function
    assert %{kind: "lexical_candidate", module: "Demo.Sample", function: "echo", arity: 2} = call
    assert slice(bytes, module) == "Demo.Call"
    assert slice(bytes, function) == "run"
    assert slice(bytes, call) == "Demo.Sample.echo"
  end

  test "rejects the entire file on unsupported syntax" do
    for declaration <- [
          "def case(), do: 0",
          "def run(x, x), do: x",
          "def run(), do: x",
          "def run(), do: Demo.Other.go(x)",
          "def run(), do: Demo.Other.go(Demo.Other.go())",
          "def run(), do: 01",
          "def run(), do: 1 # comment",
          ~S(def run(), do: "#{x}"),
          ~S(def run(), do: "a\nb")
        ] do
      assert :unsupported =
               Lexical.extract("defmodule Demo do\n  def keep(), do: 0\n  #{declaration}\nend")
    end
  end

  test "enforces file boundaries and accepts empty arguments and repeated reads" do
    valid = "defmodule Demo do\n\tdefp run(x), do: Demo.go(x, x)\nend\n# done"
    assert {:ok, [_, %{visibility: "private"}], [%{arity: 2}]} = Lexical.extract(valid)
    assert :unsupported = Lexical.extract(valid <> "\nend")
    assert :unsupported = Lexical.extract(String.replace(valid, "Demo do", "Elixir.Demo do"))
    assert :unsupported = Lexical.extract(<<255>>)
    assert :unsupported = Lexical.extract("defmodule Demo do\nend\r")
  end

  defp slice(bytes, item) do
    binary_part(bytes, item.start_byte, item.end_byte - item.start_byte)
  end
end
