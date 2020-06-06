defmodule Csp do
  @moduledoc """
  Constraint satisfaction problem definition & solver interface.
  """
  alias Csp.{Constraint, AC3, Backtracking, MinConflicts, Searcher}

  @type variable :: atom
  @type value :: any
  @type domain :: [value]
  @type constraint :: (value -> boolean) | (value, value -> boolean)
  @type assignment :: %{variable => value}

  # @type solver_status :: :solved | :reduced | :no_solution
  # @type solver_result :: {solver_status, t()}
  @type solve_result :: {:solved, assignment() | [assignment()]} | :no_solution

  @type t :: %__MODULE__{
          variables: [atom],
          domains: %{variable => domain},
          constraints: [Constraint.t()]
        }

  defstruct [:variables, :domains, :constraints]

  @doc """
  Solves a CSP.

  ## Options

  The following `opts` are supported:

  - `method`, can be one of the following:
    - `:backtracking` - backtracking search, selected by default
    - `:min_conflicts` - min-conflicts algorithm with tabu search
    - `:ac3` - AC-3 algorithm followed by backtracking
    - `:brute_force` - brute-force search.

  You can pass options to backtracking (see `Backtracking.solve/2` docs),
  min-conflicts (`MinConflicts.solve/2`), or brute-force (see `Searcher.brute_force/2`)
  in this function's `opts`.
  """
  @spec solve(t(), Keyword.t()) :: solve_result()
  def solve(%__MODULE__{} = csp, opts \\ []) do
    method = Keyword.get(opts, :method, :backtracking)

    case method do
      :backtracking ->
        Backtracking.solve(csp, opts)

      :min_conflicts ->
        MinConflicts.solve(csp, opts)

      :brute_force ->
        Searcher.brute_force(csp, opts)

      :ac3 ->
        case AC3.solve(csp) do
          {status, csp} when status in [:solved, :reduced] -> Backtracking.solve(csp, opts)
          {:no_solution, _} -> :no_solution
        end
    end
  end

  @doc """
  Checks if `assignment` solves constraint satisfaction `problem`.
  """
  @spec solved?(problem :: t(), assignment()) :: boolean()
  def solved?(%__MODULE__{constraints: constraints}, assignment) do
    Enum.all?(constraints, &Constraint.satisfies?(&1, assignment))
  end

  @doc """
  Returns a list of all constraints in `csp`
  that have `variable` as one of their arguments.
  """
  @spec constraints_on(t(), variable()) :: [Constraint.t()]
  def constraints_on(csp, variable) do
    Enum.filter(csp.constraints, fn constraint ->
      variable in Constraint.arguments(constraint)
    end)
  end

  @doc """
  Checks if (possibly partial) `assignment` satisfies all constraints in `csp`,
  for which it has enough assigned variables.
  """
  @spec consistent?(t(), assignment()) :: boolean()
  def consistent?(csp, assignment) do
    assigned_variables = Map.keys(assignment) |> MapSet.new()

    Enum.all?(csp.constraints, fn constraint ->
      arguments = Constraint.arguments(constraint)

      if Enum.all?(arguments, fn arg -> arg in assigned_variables end) do
        Constraint.satisfies?(constraint, assignment)
      else
        # if we don't have all required assignments to check the constraint, skip it
        true
      end
    end)
  end

  @doc """
  Returns a list of variables from `assignmnet` that violate constraints in `csp`.
  """
  @spec conflicted(t(), assignment()) :: [variable()]
  def conflicted(csp, assignmnet) do
    Map.keys(assignmnet)
    |> Enum.filter(fn variable ->
      constraints_on(csp, variable)
      |> Enum.any?(fn constraint -> !Constraint.satisfies?(constraint, assignmnet) end)
    end)
  end

  @doc """
  Returns a count of conflicts with `assignment` in `csp`,
  i.e. constraints that the `assignment breaks.
  """
  @spec count_conflicts(t(), assignment()) :: non_neg_integer()
  def count_conflicts(csp, assignment) do
    Enum.count(csp.constraints, fn constraint ->
      !Constraint.satisfies?(constraint, assignment)
    end)
  end

  @doc """
  Returns a `value` for `variable` that will produce the minimal number of conflicts
  in `csp` with `assignment`.
  """
  @spec min_conflicts_value!(t(), variable(), assignment()) :: value()
  def min_conflicts_value!(csp, variable, assignment) do
    Map.fetch!(csp.domains, variable)
    |> Enum.min_by(fn value ->
      assignment = Map.put(assignment, variable, value)
      count_conflicts(csp, assignment)
    end)
  end

  @doc """
  Orders values from `variable`'s domain by number of violated
  constraints the `variable` participates in in the `assignment`
  for `csp`.fun()
  """
  @spec order_by_conflicts(t(), variable(), assignment()) :: [value()]
  def order_by_conflicts(csp, variable, assignment) do
    Map.fetch!(csp.domains, variable)
    |> Enum.sort_by(fn value ->
      assignment = Map.put(assignment, variable, value)
      count_conflicts(csp, assignment)
    end)
  end
end
