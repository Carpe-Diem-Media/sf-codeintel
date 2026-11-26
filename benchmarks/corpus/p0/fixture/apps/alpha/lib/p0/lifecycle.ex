defmodule P0.Lifecycle do
  def before_edit(), do: :before
  def consumer(), do: before_edit()
  def retired_ref(), do: P0.Retired.marker()
  def moved_ref(), do: P0.Moved.marker()
end
