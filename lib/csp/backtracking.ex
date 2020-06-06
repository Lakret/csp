defmodule Csp.Backtracking do
  @moduledoc """
  Backtracking algorithm implementation.
  """
  alias Csp
  alias Csp.AC3

  @type variable_selector :: :take_head | ([Csp.variable()] -> {Csp.variable(), [Csp.variable()]})

  @doc """
  Backtracking implementation for solving CSPs.

  ## Options

  The following `opts` are supported:

  - `all`, boolean, `false` by default: if only first, or all variables should be returned.
  - `ac3`, boolean, `false` by default: if AC3 runs should be performed during each backtracking step.
  - `variable_selector`, either `:take_head` (default), `:minimum_remaining_values`
  (will select the variable with the least values remaining in the domain as the next candidate to consider),
  or a function accepting a list of unassigned variables, and returning a tuple
  of a variable we should consider next and a rest of the unassigned variables list.
  """
  @spec solve(Csp.t(), Keyword.t()) :: Csp.solve_result()
  def solve(%Csp{} = csp, opts \\ []) do
    all = Keyword.get(opts, :all, false)
    ac3 = Keyword.get(opts, :ac3, false)
    variable_selector = Keyword.get(opts, :variable_selector, :take_head)

    case backtrack(%{}, csp.variables, csp, variable_selector, ac3, all) do
      [] -> :no_solution
      [solution] -> {:solved, solution}
      solutions when is_list(solutions) -> {:solved, solutions}
    end
  end

  ## Helpers

  @spec backtrack(Csp.assignment(), [Csp.variable()], Csp.t(), variable_selector(), boolean(), boolean()) ::
          [Csp.assignment()]
  defp backtrack(assignment, unassigned_variables, csp, variable_selector, ac3, all)

  defp backtrack(assignment, [] = _unassigned, _, _, _, _), do: [assignment]

  defp backtrack(assignment, [unassigned_variable | rest], csp, :take_head, ac3, all) do
    backtrack_variable_selected(assignment, {unassigned_variable, rest}, csp, :take_head, ac3, all)
  end

  defp backtrack(assignment, unassigned_variables, csp, :minimum_remaining_values, ac3, all) do
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

    backtrack_variable_selected(assignment, {unassigned_variable, rest}, csp, :minimum_remaining_values, ac3, all)
  end

  defp backtrack(assignment, unassigned_variables, csp, variable_selector, run_ac3, all) do
    {unassigned_variable, rest} = variable_selector.(unassigned_variables)

    backtrack_variable_selected(assignment, {unassigned_variable, rest}, csp, variable_selector, run_ac3, all)
  end

  defp backtrack_variable_selected(assignment, {variable, unassigned}, csp, variable_selector, ac3, all) do
    domain = Map.fetch!(csp.domains, variable)

    Enum.reduce_while(domain, [], fn value, acc ->
      assignment = Map.put(assignment, variable, value)

      if Csp.consistent?(csp, assignment) do
        {inconsistent, csp, assignment, unassigned} =
          if ac3 do
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
          future_result = backtrack(assignment, unassigned, csp, variable_selector, ac3, all)

          case future_result do
            [] ->
              {:cont, acc}

            solutions when is_list(solutions) ->
              if all, do: {:cont, acc ++ solutions}, else: {:halt, solutions}
          end
        end
      else
        {:cont, acc}
      end
    end)
  end
end
