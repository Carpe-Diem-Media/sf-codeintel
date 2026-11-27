defmodule SFCodeIntel.MixProject do
  use Mix.Project

  def project do
    [
      app: :sf_codeintel,
      version: "0.1.0",
      elixir: "~> 1.19.3",
      deps: [],
      escript: [main_module: SFCodeIntel.CLI, name: "sf-codeintel", path: "_build/sf-codeintel"]
    ]
  end

  def application, do: [extra_applications: [:crypto]]
end
