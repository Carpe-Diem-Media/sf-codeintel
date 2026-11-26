defmodule P0.Refs do
  alias P0.Exact, as: Pick

  def outer(), do: Pick.same()

  defmodule Inner do
    alias P0.Alternate, as: Pick

    def inner(), do: Pick.same()
  end
end

defmodule P0.Alternate do
  def same(), do: :alternate
end

defmodule P0.Imported do
  import P0.Exact, only: [same: 1]

  def accepted(value), do: same(value)
  def excluded(), do: same()
end

defmodule P0.Proxy do
  defdelegate echo(value), to: P0.Exact, as: :same
end

defmodule P0.Palette do
  @behaviour P0.Contract

  def shade(value), do: value
end
