defmodule Csp do
  @moduledoc """
  Constraint satisfaction problem definition & solver interface.
  """
  alias Csp.{Constraint, AC3, Searcher}

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
  Solves a CSP using a combination of AC3 and brute force search.

  ## Options

  - `ac3`, boolean, defaults to `true`: specifies if AC3 should be used to reduce
  the domain of variables before performing brute force search.

  Any additional options will be passed to `Searcher.brute_force/1`.
  """
  @spec solve(Csp.t(), Keyword.t()) :: :no_solution | {:solved, assignment() | [assignment()]}
  def solve(%__MODULE__{} = csp, opts \\ []) do
    ac3 = Keyword.get(opts, :ac3, true)

    if ac3 do
      case AC3.solve(csp) do
        # brute force will just construct the solution if `:solved`, and search for it if `:reduced`.
        {status, csp} when status in [:solved, :reduced] -> Searcher.brute_force(csp, opts)
        {:no_solution, _} -> :no_solution
      end
    else
      Searcher.brute_force(csp)
    end
  end

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
  @spec squares_csp() :: t()
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
