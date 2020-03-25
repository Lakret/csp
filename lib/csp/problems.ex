defmodule Csp.Problems do
  @moduledoc """
  Test constraint satisfaction problems.
  """

  @doc """
  Returns an example Csp struct for the following problem:

  ```
  Y = X ^ 2
  where X, Y are digits
  ```
  """
  @spec squares_csp() :: Csp.t()
  def squares_csp() do
    digit_domain = 0..9 |> Enum.to_list()

    %Csp{
      variables: [:x, :y],
      domains: %{x: digit_domain, y: digit_domain},
      constraints: [
        {[:x, :y], fn x, y -> y == x * x end}
      ]
    }
  end

  @doc """
  Returns an instance of a constraint satisfaction problem
  for map coloring of Australia.
  """
  @spec map_coloring_csp() :: Csp.t()
  def map_coloring_csp() do
    states = ~w(WA NT Q NSW V SA T)a
    domains = for state <- states, do: {state, ~w(red green blue)a}, into: %{}

    inequalities = [
      [:SA, :WA],
      [:SA, :NT],
      [:SA, :Q],
      [:SA, :NSW],
      [:SA, :V],
      [:WA, :NT],
      [:NT, :Q],
      [:Q, :NSW],
      [:NSW, :V]
    ]

    constraints = Enum.map(inequalities, fn args -> {args, &!=/2} end)

    %Csp{variables: states, domains: domains, constraints: constraints}
  end

  @doc """
  Returns an example of a correct solution of the map coloring Csp.
  """
  @spec map_coloring_example_solution :: Csp.assignment()
  def map_coloring_example_solution() do
    %{WA: :red, NT: :green, Q: :red, NSW: :green, V: :red, SA: :blue, T: :red}
  end

  @doc """
  Returns an example of a wrong solution of the map coloring Csp.
  """
  @spec map_coloring_wrong_solution :: Csp.assignment()
  def map_coloring_wrong_solution() do
    %{WA: :green, NT: :red, Q: :red, NSW: :green, V: :red, SA: :blue, T: :red}
  end
end
