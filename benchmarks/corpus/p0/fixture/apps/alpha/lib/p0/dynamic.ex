defmodule P0.Dynamic do
  def by_name(module, name), do: apply(module, name, [])
  def by_fun(fun), do: fun.(:blue)
  def from_catalog(name), do: apply(P0.Catalog, name, [])
  def generated(), do: P0.Catalog.list_colors()
end
