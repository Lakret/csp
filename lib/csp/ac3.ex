defmodule Csp.AC3 do
  @moduledoc """
  Pure AC-3 algorithm implementation.
  """
  alias Csp.Constraint

  @doc """
  Tries to solve `csp` with AC-3 algorithm, applying node and arc consistency.

  Only considers unary and binary constraints; will skip n-ary constraints where n > 2.

  Returns a tuple `{status, csp}`.

  The returned `csp` will possibly have reduced `domains`.
  If all variables have domain length of 1, we found a solution (`:solved` status is returned).
  If any variable has a domain length of 0, we proved that `csp` is not solvable,
  and `:no_solution` status is returned.
  If neither of those conditions is true, `:reduced` status is returend, irrespective of
  any actual domain reduction occuring.
  """
  @spec solve(Csp.t()) :: Csp.solver_result()
  def solve(csp) do
    csp = solve(csp, csp.constraints)

    status = analyze(csp)
    {status, csp}
  end

  # Helpers

  @spec solve(Csp.t(), [constraint :: any()]) :: Csp.t()
  defp solve(csp, constraints)

  defp solve(csp, [] = _constraint), do: csp

  defp solve(csp, [constraint | rest]) do
    case Constraint.arguments(constraint) do
      # node consistency for unary constraints
      [variable] ->
        original_domain = Map.fetch!(csp.domains, variable)

        reduced_domain =
          Enum.filter(original_domain, fn value ->
            Constraint.satisfies?(constraint, %{variable => value})
          end)

        {csp, affected_dependents} =
          apply_domain_reduction(csp, constraint, variable, original_domain, reduced_domain)

        constraints =
          case affected_dependents do
            [] -> rest
            _ -> Enum.uniq(rest ++ affected_dependents)
          end

        solve(csp, constraints)

      # arc consistency for binary constraints
      [x, y] ->
        {csp, constraints_to_consider_from_x} = enforce_arc_consistency(csp, constraint, x, y)
        {csp, constraints_to_consider_from_y} = enforce_arc_consistency(csp, constraint, y, x)

        constraints =
          Enum.uniq(rest ++ constraints_to_consider_from_x ++ constraints_to_consider_from_y)

        solve(csp, constraints)

      # don't attempt to solve for higher arity constraints for now
      k_ary when is_list(k_ary) ->
        csp
    end
  end

  @spec enforce_arc_consistency(Csp.t(), Constraint.t(), Csp.variable(), Csp.variable()) ::
          {Csp.t(), [Constraint.t()]}
  defp enforce_arc_consistency(csp, constraint, x, y) do
    x_original_domain = Map.fetch!(csp.domains, x)
    y_original_domain = Map.fetch!(csp.domains, y)

    x_reduced_domain =
      Enum.filter(x_original_domain, fn x_value ->
        Enum.any?(y_original_domain, fn y_value ->
          Constraint.satisfies?(constraint, %{x => x_value, y => y_value})
        end)
      end)

    apply_domain_reduction(csp, constraint, x, x_original_domain, x_reduced_domain)
  end

  @spec apply_domain_reduction(
          Csp.t(),
          Constraint.t(),
          Csp.variable(),
          Csp.domain(),
          Csp.domain()
        ) :: {Csp.t(), [Constraint.t()]}
  defp apply_domain_reduction(csp, constraint, variable, original_domain, reduced_domain) do
    if length(reduced_domain) < length(original_domain) do
      csp = %{csp | domains: Map.put(csp.domains, variable, reduced_domain)}

      affected_dependents =
        Csp.constraints_on(csp, variable)
        |> List.delete(constraint)

      {csp, affected_dependents}
    else
      {csp, []}
    end
  end

  @spec analyze(Csp.t()) :: Csp.solver_status()
  defp analyze(csp) do
    Enum.reduce_while(csp.domains, :solved, fn {_variable, domain}, status ->
      case length(domain) do
        0 -> {:halt, :no_solution}
        1 -> {:cont, status}
        _ -> {:halt, :reduced}
      end
    end)
  end
end
