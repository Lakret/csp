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
        # brute force will just construct the solution if `:solved`, and search for it if `:reduced`
        {status, csp} when status in [:solved, :reduced] -> Searcher.brute_force(csp, opts)
        {:no_solution, _} -> :no_solution
      end
    else
      Searcher.brute_force(csp, opts)
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
end
