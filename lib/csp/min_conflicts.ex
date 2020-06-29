defmodule Csp.MinConflicts do
  @moduledoc """
  [Min-conflicts](https://en.wikipedia.org/wiki/Min-conflicts_algorithm) algorithm implementation,
  with Tabu search to allow overcoming local minimums.
  """

  @doc """
  Solves `csp` with min-conflicts algorithm, using tabu search to overcome local minimums.

  ## Options

  Supported `opts`:

    - `:max_iteration` - positive integer, the number of iteration to perform before giving up.
    Defaults to `10_000`.
    - `:optimize_initial_state` - boolean, defaults to `false`. If set to `true`, will use a greedy
    algorithm to set an initial state minimizing the number of conflicts for each variable.
    - `:tabu_depth` - positive integer or `nil`, defaults to `nil`. If set to an integer,
    will limit tabu stack depth by the specified integer.
  """
  @spec solve(Csp.t(), Keyword.t()) :: {:solved, Csp.assignment()} | :no_solution
  def solve(csp, opts \\ []) do
    max_iterations = Keyword.get(opts, :max_iterations, 10_000)
    optimize_initial_state = Keyword.get(opts, :optimize_initial_state, false)
    tabu_depth = Keyword.get(opts, :tabu_depth)

    assignment = if optimize_initial_state, do: optimized_initial_state(csp), else: random_initial_state(csp)

    {status, assignment, _tabu} =
      1..max_iterations
      |> Enum.reduce_while({:no_solution, assignment, []}, fn _iteration, {status, assignment, tabu} ->
        # TODO: replace with Csp.solved?, since it's cheaper, and we always have full assignment here.
        if Csp.consistent?(csp, assignment) do
          {:halt, {:solved, assignment, tabu}}
        else
          variable = Csp.conflicted(csp, assignment) |> Enum.random()
          random_value = Enum.random(csp.domains[variable])

          # TODO: Make tabu a MapSet?
          # TODO: replace find with manual reduce_while to take the first value that is not in tabu, or generate a default value if it's not found
          # TODO: try with prohibiting the current value of the variable; or, better still, placing all current values in tabu before starting this
          # TODO: more optimal representation for the n queens constraints as atoms
          value =
            Csp.order_by_conflicts(csp, variable, assignment)
            |> Enum.find(random_value, fn value -> {variable, value} not in tabu end)

          tabu = [{variable, value} | tabu]

          tabu =
            if tabu_depth && length(tabu) > tabu_depth do
              Enum.take(tabu, tabu_depth)
            else
              tabu
            end

          {:cont, {status, Map.put(assignment, variable, value), tabu}}
        end
      end)

    if status == :no_solution, do: status, else: {status, assignment}
  end

  ## Helpers

  @spec random_initial_state(Csp.t()) :: Csp.assignment()
  defp random_initial_state(%Csp{} = csp) do
    Enum.reduce(csp.domains, %{}, fn {variable, values}, assignment ->
      value = Enum.random(values)
      Map.put(assignment, variable, value)
    end)
  end

  @spec optimized_initial_state(Csp.t()) :: Csp.assignment()
  defp optimized_initial_state(%Csp{} = csp) do
    Enum.reduce(csp.variables, %{}, fn variable, assignment ->
      value =
        try do
          Csp.min_conflicts_value!(csp, variable, assignment)
        rescue
          KeyError ->
            Map.fetch!(csp.domains, variable) |> Enum.random()
        end

      Map.put(assignment, variable, value)
    end)
  end
end
