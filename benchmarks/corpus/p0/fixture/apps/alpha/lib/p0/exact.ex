defmodule P0.Exact do
  def same(), do: :zero
  def same(value), do: value
  defp local(value), do: value

  def choose(:red), do: local(:red)
  def choose(value), do: local(value)

  def greet(name, tone \\ :plain), do: {name, tone}
end
