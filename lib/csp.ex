defmodule CSP do
  @moduledoc """
  Constraint satisfaction problem definition & solver interface.
  """
  alias CSP.Constraint

  @type variable :: atom
  @type value :: any
  @type domain :: [value]
  @type constraint :: (value -> boolean) | (value, value -> boolean)
  @type assignment :: %{variable => value}

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

  # TODO: report first violated constraint when checking for solution
  # TODO: before stream: basic Rustler installation to test speed difference
  # TODO:
  #   - cryptarithmetic example
  #   - sudoku
  #   - AC-3
  #   - backtracking

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
  Returns an example of a correct solution of the map coloring CSP.
  """
  @spec map_coloring_example_solution :: assignment()
  def map_coloring_example_solution() do
    %{WA: :red, NT: :green, Q: :red, NSW: :green, V: :red, SA: :blue, T: :red}
  end

  @doc """
  Returns an example of a wrong solution of the map coloring CSP.
  """
  @spec map_coloring_wrong_solution :: assignment()
  def map_coloring_wrong_solution() do
    %{WA: :green, NT: :red, Q: :red, NSW: :green, V: :red, SA: :blue, T: :red}
  end
end
