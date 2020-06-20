defmodule Csp.MixProject do
  use Mix.Project

  @version "0.1.0"
  @description "Pure Elixir Constraint Satisfaction problem solvers"

  def project do
    [
      app: :csp,
      version: @version,
      description: @description,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      package: package(),
      name: "csp",
      escript: [main_module: Csp.CLI],
      deps: deps(),
      compilers: Mix.compilers()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Csp.Application, []}
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:benchee, "~> 1.0", only: :dev},
      # {:benchee_html, "~> 1.0", only: :dev},
      {:benchee_csv, "~> 1.0", only: :dev}
    ]
  end

  defp package do
    %{
      licenses: ["Apache 2", "MIT"],
      maintainers: ["Dmitry Slutsky"],
      links: %{"GitHub" => "https://github.com/Lakret/csp"}
    }
  end
end
