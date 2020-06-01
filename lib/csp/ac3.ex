defmodule Csp.AC3 do
  @moduledoc """
  Pure AC-3 algorithm implementation.

  Also provides `reduce/3` helper that can be used as an inference part of search algorithms.
  """
  alias Csp.Constraint

  @type unassigned :: [Csp.variable()]
  @type domain_reduction :: {Csp.t(), Csp.assignment(), unassigned()}
  @type reduce_result :: {:ok, Csp.t(), Csp.assignment(), unassigned()} | :no_solution

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

  @doc """
  Reduces the `csp` with AC-3.

  Accepts `csp` with `assignment` (map from variables to their assigned values),
  and a list of `unassigned` variables.

  Compared to `solve/2`, apart from tracking the assignment, it also uses
  simplified version of domain reduction for constraint: it doesn't attempt
  to track affected constraints when reducing some constraint's domain.

  Returns `:no_solution` if an inconsistency is detected, or a tuple of
  `{:ok, csp, assignment, unassigned}`, where domains of `csp` are reduced,
  `assignment` is amended with inferred variable assignments, and
  `unassigned` list is updated to reflect those assignment changes.
  """
  @spec reduce(Csp.t(), Csp.assignment(), unassigned()) :: reduce_result()
  def reduce(csp, assignment, unassigned) do
    reduce(csp, assignment, unassigned, csp.constraints)
  end

  ## Helpers

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
          reduce_domain(csp, constraint, variable, original_domain, reduced_domain)

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

      # skip higher arity constraints
      k_ary when is_list(k_ary) ->
        solve(csp, rest)
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

    reduce_domain(csp, constraint, x, x_original_domain, x_reduced_domain)
  end

  @spec reduce_domain(Csp.t(), Constraint.t(), Csp.variable(), Csp.domain(), Csp.domain()) ::
          {Csp.t(), [Constraint.t()]}
  defp reduce_domain(csp, constraint, variable, original_domain, reduced_domain) do
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

  @spec reduce(Csp.t(), Csp.assignment(), unassigned(), [Csp.constraint()]) :: reduce_result()
  defp reduce(csp, assignment, unassigned, constraints)

  defp reduce(csp, assignment, unassigned, []), do: {:ok, csp, assignment, unassigned}

  defp reduce(csp, assignment, unassigned, [constraint | remaining_constraints]) do
    case Constraint.arguments(constraint) do
      # node consistency for unary constraints
      [variable] ->
        original_domain = Map.fetch!(csp.domains, variable)

        reduced_domain =
          Enum.filter(original_domain, fn value ->
            Constraint.satisfies?(constraint, %{variable => value})
          end)

        case reduced_domain do
          [] ->
            :no_solution

          _ ->
            {csp, assignment, unassigned} =
              reduce_domain_and_assign(csp, variable, assignment, unassigned, reduced_domain)

            reduce(csp, assignment, unassigned, remaining_constraints)
        end

      # arc consistency for binary constraints
      [x, y] ->
        {csp, assignment, unassigned} =
          enforce_arc_consistency_and_assign(csp, constraint, assignment, unassigned, x, y)

        {csp, assignment, unassigned} =
          enforce_arc_consistency_and_assign(csp, constraint, assignment, unassigned, y, x)

        reduce(csp, assignment, unassigned, remaining_constraints)

      # skip higher arity constraints
      k_ary when is_list(k_ary) ->
        reduce(csp, assignment, unassigned, remaining_constraints)
    end
  end

  @spec reduce_domain_and_assign(
          Csp.t(),
          Csp.variable(),
          Csp.assignment(),
          unassigned(),
          Csp.domain()
        ) :: domain_reduction()
  defp reduce_domain_and_assign(csp, variable, assignment, unassigned, reduced_domain) do
    original_domain = Map.fetch!(csp.domains, variable)
    domain_length = length(reduced_domain)

    if domain_length < length(original_domain) do
      csp = %{csp | domains: Map.put(csp.domains, variable, reduced_domain)}

      if domain_length == 1 do
        assignment = Map.put(assignment, variable, hd(reduced_domain))
        unassigned = List.delete(unassigned, variable)

        {csp, assignment, unassigned}
      else
        {csp, assignment, unassigned}
      end
    else
      {csp, assignment, unassigned}
    end
  end

  @spec enforce_arc_consistency_and_assign(
          Csp.t(),
          Csp.constraint(),
          Csp.assignment(),
          unassigned(),
          Csp.variable(),
          Csp.variable()
        ) :: domain_reduction()
  defp enforce_arc_consistency_and_assign(csp, constraint, assignment, unassigned, x, y) do
    x_original_domain = Map.fetch!(csp.domains, x)
    y_original_domain = Map.fetch!(csp.domains, y)

    x_reduced_domain =
      Enum.filter(x_original_domain, fn x_value ->
        Enum.any?(y_original_domain, fn y_value ->
          Constraint.satisfies?(constraint, %{x => x_value, y => y_value})
        end)
      end)

    reduce_domain_and_assign(csp, x, assignment, unassigned, x_reduced_domain)
  end
end
