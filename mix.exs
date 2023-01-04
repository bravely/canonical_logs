defmodule CanonicalLogs.MixProject do
  use Mix.Project

  def project do
    [
      app: :canonical_logs,
      version: "0.1.0",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "Canonical Logs",
      source_url: "https://github.com/bravely/canonical_logs",
      homepage_url: "https://github.com/bravely/canonical_logs",
      main: "README",
      aliases: aliases(),
      preferred_cli_env: ["test.ci": :test]
    ]
  end

  defp elixirc_paths(:test),
    do: ["lib", "test/support"]

  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.11"},
      {:telemetry, "~> 1.0"},
      {:absinthe, "~> 1.6.3", optional: true},
      {:absinthe_plug, "~> 1.5", only: [:dev, :test]},
      {:jason, "~> 1.4", only: [:dev, :test]},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      "test.ci": ["test --color --max-cases=10"]
    ]
  end
end
