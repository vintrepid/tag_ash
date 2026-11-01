defmodule TagAsh.MixProject do
  use Mix.Project

  @version "0.1.0-alpha.1"
  @source_url "https://github.com/vintrepid/tag_ash"

  def project do
    [
      app: :tag_ash,
      version: @version,
      elixir: "~> 1.20",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Reusable hierarchical classification for Ash applications",
      package: package(),
      source_url: @source_url
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ash_ri, github: "vintrepid/ash_ri", ref: "de13c28039041972c8c03597611708ae4e07e4e0"},
      {:ash, "~> 3.37 and >= 3.37.2"},
      {:ash_postgres, "~> 2.15 and >= 2.15.2"},
      {:sourceror, "~> 1.13", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Vince Nibler"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE AGENTS.md)
    ]
  end
end
