defmodule Csp.MinConflicts do
  @moduledoc """
  [Min-conflicts](https://en.wikipedia.org/wiki/Min-conflicts_algorithm) algorithm implementation.
  """

  # TODO: try tabu search to prevent the min conflicts algorithm to become stuck?
  # TODO: extract search result here and in backtracking / brute force searches / AC3

  @test """
  alias Csp.{Problems, MinConflicts, Searcher}

  csp = Problems.nqueens(4)
  assignment = MinConflicts.solve(csp) |> IO.inspect(label: :assignment)
  Csp.Problems.pretty_print_nqueens(assignment, 4)

  Csp.conflicted(csp, assignment)
  Csp.count_conflicts(csp, assignment)

  {:solved, [solution]} = Searcher.backtrack(csp)
  Csp.conflicted(csp, solution)
  Csp.count_conflicts(csp, solution)

  MinConflicts.solve(csp) |> Problems.pretty_print_nqueens(4)


  csp = Problems.nqueens(3)
  MinConflicts.solve(csp)
  """

  @doc """
  TODO:
  """
  @spec solve(Csp.t(), Keyword.t()) :: {:solved, Csp.assignment()} | :no_solution
  def solve(csp, opts \\ []) do
    max_iterations = Keyword.get(opts, :max_iterations, 10_000)

    # :rand.seed(:exsss, Time.utc_now() |> Time.to_erl())

    # greedy good initial state generation
    # assignment =
    #   Enum.reduce(csp.variables, %{}, fn variable, assignment ->
    #     value =
    #       try do
    #         Csp.min_conflicts_value!(csp, variable, assignment)
    #       rescue
    #         KeyError ->
    #           Map.fetch!(csp.domains, variable) |> Enum.random()
    #       end
    #     Map.put(assignment, variable, value)
    #   end)

    assignment =
      Enum.reduce(csp.domains, %{}, fn {variable, values}, assignment ->
        value = Enum.random(values)
        Map.put(assignment, variable, value)
      end)

    {status, assignment, _tabu} =
      1..max_iterations
      |> Enum.reduce_while({:no_solution, assignment, []}, fn _iteration,
                                                              {status, assignment, tabu} ->
        if Csp.consistent?(csp, assignment) do
          {:halt, {:solved, assignment, tabu}}
        else
          # TODO: how to prevent it from cycling non-stop?
          variable = Csp.conflicted(csp, assignment) |> Enum.random()
          # |> IO.inspect(label: :variable)

          # conflicted_variables = Csp.conflicted(csp, assignment)
          # random_index = :rand.uniform(length(conflicted_variables)) - 1
          # variable = Enum.at(conflicted_variables, random_index) |> IO.inspect(label: :variable)

          # variable = Enum.random(csp.variables) |> IO.inspect(label: :variable)

          # value = Csp.min_conflicts_value!(csp, variable, assignment)
          min_conflicts_value = Csp.min_conflicts_value!(csp, variable, assignment)

          value =
            Csp.order_by_conflicts(csp, variable, assignment)
            |> Enum.find(fn value -> {variable, value} not in tabu end)

          value = value || min_conflicts_value

          tabu = [{variable, value} | tabu]

          {:cont, {status, Map.put(assignment, variable, value), tabu}}
        end
      end)

    if status == :no_solution, do: status, else: {status, assignment}
  end
end
