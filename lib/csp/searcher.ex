defmodule Csp.Searcher do
  @moduledoc """
  Search strategies for CSP.
  """

  @type search_result :: {:solved, Csp.assignment() | [Csp.assignment()]} | :no_solution

  @doc """
  Performs a brute force search on `csp`.

  If solution is found, returned `{:solved, assignment}`, otherwise returns `:no_solution`.

  ## Options

  - `all`, boolean: if all solutions should be found. By default is set to `false`,
  so only the first found solution is returned. If `all` is true, all solutions are found,
  and instead of returning a single `assignment`, returns a list of `assignments`.
  """
  @spec brute_force(Csp.t(), Keyword.t()) :: search_result()
  def brute_force(%Csp{} = csp, opts \\ []) do
    all = Keyword.get(opts, :all, false)

    candidates = generate_candidates(csp)

    solution_or_solutions =
      if all do
        Enum.filter(candidates, &Csp.solved?(csp, &1))
      else
        Enum.find(candidates, &Csp.solved?(csp, &1))
      end

    if is_nil(solution_or_solutions) do
      :no_solution
    else
      {:solved, solution_or_solutions}
    end
  end

  @doc """
  Simple backtracking implementation.

  Results & opts the same as in `brute_force/2`.
  """
  @spec backtrack(Csp.t(), Keyword.t()) :: search_result()
  def backtrack(%Csp{} = csp, opts \\ []) do
    all = Keyword.get(opts, :all, false)

    solutions = backtrack(%{}, csp.variables, csp, all)

    case solutions do
      [] -> :no_solution
      solutions when is_list(solutions) -> {:solved, solutions}
    end
  end

  @spec backtrack(Csp.assignment(), [Csp.variable()], Csp.t(), boolean()) :: [Csp.assignment()]
  def backtrack(assignment, unassigned_variables, csp, all)

  def backtrack(assignment, [] = _unassigned, _csp, _all), do: [assignment]

  def backtrack(assignment, [unassigned_variable | rest], csp, all) do
    # TODO: select_unassigned_variable and order_domain_values
    domain = Map.fetch!(csp.domains, unassigned_variable)

    Enum.reduce_while(domain, [], fn value, acc ->
      candidate_assignment = Map.put(assignment, unassigned_variable, value)

      if Csp.consistent?(csp, candidate_assignment) do
        # TODO: inferences
        future_result = backtrack(candidate_assignment, rest, csp, all)

        case future_result do
          [] -> {:cont, acc}
          [solution] -> if all, do: {:cont, [solution | acc]}, else: {:halt, [solution]}
        end
      else
        {:cont, acc}
      end
    end)
  end

  @doc """
  Returns a list of all possible assignments of variables in `csp`.
  """
  @spec generate_candidates(Csp.t()) :: [Csp.assignment()]
  def generate_candidates(csp) do
    generate_candidates(csp, csp.variables, [])
  end

  ## Helpers

  @spec generate_candidates(Csp.t(), [Csp.variable()], [Csp.assignment()]) :: [Csp.assignment()]
  defp generate_candidates(csp, variables_to_consider, candidates)

  defp generate_candidates(_csp, [], candidates), do: candidates

  defp generate_candidates(csp, [variable | rest], candidates) do
    domain = Map.fetch!(csp.domains, variable)

    case candidates do
      [] ->
        candidates = Enum.map(domain, fn value -> %{variable => value} end)
        generate_candidates(csp, rest, candidates)

      _ ->
        candidates_with_variable =
          Enum.reduce(domain, [], fn value, candidates_with_variable ->
            candidates_with_variable ++ Enum.map(candidates, &Map.put(&1, variable, value))
          end)

        generate_candidates(csp, rest, candidates_with_variable)
    end
  end
end
