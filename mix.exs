defmodule Csp.MixProject do
  use Mix.Project

  def project do
    [
      app: :csp,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      escript: [main_module: Csp.CLI],
      deps: deps(),
      compilers: Mix.compilers()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Csp.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false}
    ]
  end
end
