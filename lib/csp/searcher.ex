defmodule Csp.Searcher do
  @moduledoc """
  Search strategies for CSP.
  """
  require Logger

  alias Csp.AC3

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

  Results are the same as in `brute_force/2`.

  The following `opts` are supported:

  - `all`, boolean, `false` by default: if only first, or all variables should be returned.
  - `ac3`, boolean, `false` by default: if AC3 runs should be performed during each backtracking step.
  - `variable_selector`, either `:take_head` (default), `:minimum_remaining_values`
  (will select the variable with the least values remaining in the domain as the next candidate to consider),
  or a function accepting a list of unassigned variables, and returning a tuple
  of a variable we should consider next and a rest of the unassigned variables list.
  """
  @spec backtrack(Csp.t(), Keyword.t()) :: search_result()
  def backtrack(%Csp{} = csp, opts \\ []) do
    all = Keyword.get(opts, :all, false)
    run_ac3 = Keyword.get(opts, :ac3, false)
    variable_selector = Keyword.get(opts, :variable_selector, :take_head)

    case backtrack(%{}, csp.variables, csp, variable_selector, run_ac3, all) do
      [] -> :no_solution
      solutions when is_list(solutions) -> {:solved, solutions}
    end
  end

  @type variable_selector :: :take_head | ([Csp.variable()] -> {Csp.variable(), [Csp.variable()]})

  @spec backtrack(
          Csp.assignment(),
          [Csp.variable()],
          Csp.t(),
          variable_selector,
          boolean(),
          boolean()
        ) ::
          [Csp.assignment()]
  defp backtrack(assignment, unassigned_variables, csp, variable_selector, run_ac3, all)

  defp backtrack(assignment, [] = _unassigned, _csp, _variable_selector, _run_ac3, _all),
    do: [assignment]

  defp backtrack(assignment, [unassigned_variable | rest], csp, :take_head, run_ac3, all) do
    backtrack_variable_selected(
      assignment,
      {unassigned_variable, rest},
      csp,
      :take_head,
      run_ac3,
      all
    )
  end

  defp backtrack(assignment, unassigned_variables, csp, :minimum_remaining_values, run_ac3, all) do
    {min_domain_values_variable, _domain} =
      Map.take(csp.domains, unassigned_variables)
      |> Enum.map(fn {variable, domain} ->
        {variable, length(domain)}
      end)
      |> Enum.min(fn {_, domain_length}, {_, domain_length2} ->
        domain_length <= domain_length2
      end)

    {unassigned_variable, rest} =
      {min_domain_values_variable, List.delete(unassigned_variables, min_domain_values_variable)}

    backtrack_variable_selected(
      assignment,
      {unassigned_variable, rest},
      csp,
      :minimum_remaining_values,
      run_ac3,
      all
    )
  end

  defp backtrack(assignment, unassigned_variables, csp, variable_selector, run_ac3, all) do
    {unassigned_variable, rest} = variable_selector.(unassigned_variables)

    backtrack_variable_selected(
      assignment,
      {unassigned_variable, rest},
      csp,
      variable_selector,
      run_ac3,
      all
    )
  end

  # TODO: order_domain_values less constraining variable heuristic

  defp backtrack_variable_selected(
         assignment,
         {variable, unassigned},
         csp,
         variable_selector,
         run_ac3,
         all
       ) do
    domain = Map.fetch!(csp.domains, variable)

    Enum.reduce_while(domain, [], fn value, acc ->
      assignment = Map.put(assignment, variable, value)

      if Csp.consistent?(csp, assignment) do
        {inconsistent, csp, assignment, unassigned} =
          if run_ac3 do
            case AC3.reduce(csp, assignment, unassigned) do
              {:ok, csp, assignment, unassigned} -> {false, csp, assignment, unassigned}
              :no_solution -> {true, csp, assignment, unassigned}
            end
          else
            {false, csp, assignment, unassigned}
          end

        if inconsistent do
          {:cont, acc}
        else
          future_result = backtrack(assignment, unassigned, csp, variable_selector, run_ac3, all)

          case future_result do
            [] ->
              {:cont, acc}

            [solution] ->
              if all, do: {:cont, [solution | acc]}, else: {:halt, [solution]}

            solutions when is_list(solutions) ->
              if all, do: {:cont, acc ++ solutions}, else: {:halt, solutions}
          end
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
