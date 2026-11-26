defmodule P0.Color do
  use Ash.Resource, domain: P0.Catalog

  actions do
    read :read
  end
end

defmodule P0.Catalog do
  use Ash.Domain

  resources do
    resource P0.Color do
      define :list_colors, action: :read
    end
  end
end
