defmodule Csp do
  @moduledoc """
  Constraint satisfaction problem definition & solver interface.
  """
  alias Csp.Constraint

  @type variable :: atom
  @type value :: any
  @type domain :: [value]
  @type constraint :: (value -> boolean) | (value, value -> boolean)
  @type assignment :: %{variable => value}

  @type solver_status :: :solved | :reduced | :no_solution
  @type solver_result :: {solver_status, t()}

  @type t :: %__MODULE__{
          variables: [atom],
          domains: %{variable => domain},
          constraints: [Constraint.t()]
        }

  defstruct [:variables, :domains, :constraints]

  @doc """
  Checks if `assignment` solves constraint satisfaction `problem`.
  """
  @spec solved?(problem :: t, assignment) :: boolean()
  def solved?(%__MODULE__{constraints: constraints}, assignment) do
    Enum.all?(constraints, &Constraint.satisfies?(&1, assignment))
  end

  @doc """
  Returns a list of all constraints in `csp`
  that have `variable` as one of their arguments.
  """
  @spec constraints_on(t(), variable) :: [Constraint.t()]
  def constraints_on(csp, variable) do
    Enum.filter(csp.constraints, fn constraint ->
      variable in Constraint.arguments(constraint)
    end)
  end

  # Example problems

  # X = 2, Y = 4
  # X = 8, Y = doesn't exist

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

    %__MODULE__{
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
  @spec map_coloring_csp() :: t()
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

    %__MODULE__{variables: states, domains: domains, constraints: constraints}
  end

  @doc """
  Returns an example of a correct solution of the map coloring Csp.
  """
  @spec map_coloring_example_solution :: assignment()
  def map_coloring_example_solution() do
    %{WA: :red, NT: :green, Q: :red, NSW: :green, V: :red, SA: :blue, T: :red}
  end

  @doc """
  Returns an example of a wrong solution of the map coloring Csp.
  """
  @spec map_coloring_wrong_solution :: assignment()
  def map_coloring_wrong_solution() do
    %{WA: :green, NT: :red, Q: :red, NSW: :green, V: :red, SA: :blue, T: :red}
  end
end
