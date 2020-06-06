defmodule Csp.Searcher do
  @moduledoc """
  Search strategies for CSP.
  """
  require Logger

  @doc """
  Performs a brute force search on `csp`.

  **NOTE:** don't use it for real stuff. This is provided only for comparison with backtracking.
  Use backtracking instead!

  If solution is found, returned `{:solved, assignment | assignments}`, otherwise returns `:no_solution`.

  ## Options

  - `all`, boolean: if all solutions should be found. By default is set to `false`,
  so only the first found solution is returned. If `all` is true, all solutions are found,
  and instead of returning a single `assignment`, returns a list of `assignments`.
  """
  @spec brute_force(Csp.t(), Keyword.t()) :: Csp.solve_result()
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

  ## Helpers

  @spec generate_candidates(Csp.t()) :: [Csp.assignment()]
  defp generate_candidates(csp) do
    generate_candidates(csp, csp.variables, [])
  end

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
