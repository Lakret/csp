defmodule Csp.AC3 do
  @moduledoc """
  Pure AC-3 algorithm implementation.
  """
  alias Csp.Constraint

  @spec solve(Csp.t()) :: Csp.solver_result()
  def solve(csp) do
    csp = solve(csp, csp.constraints)

    status = analyze(csp)
    {status, csp}
  end

  # Helpers

  @spec solve(Csp.t(), [Constriant.t()]) :: Csp.t()
  def solve(csp, [] = _constraint), do: csp

  def solve(csp, [constraint | rest]) do
    case Constraint.arguments(constraint) do
      # node consistency for unary constraints
      [variable] ->
        original_domain = Map.fetch!(csp.domains, variable)

        reduced_domain =
          Enum.filter(original_domain, fn value ->
            Constraint.satisfies?(constraint, %{variable => value})
          end)

        if length(reduced_domain) < original_domain do
          csp = %{csp | domains: Map.put(csp.domains, variable, reduced_domain)}

          dependent_constraints =
            Csp.constraints_on(csp, variable)
            |> List.delete(constraint)

          constraints = Enum.uniq(rest ++ dependent_constraints)
          solve(csp, constraints)
        else
          solve(csp, rest)
        end

      # arc consistency for binary constraints
      [x, y] ->
        {csp, constraints_to_consider_from_x} = enforce_arc_consistency(csp, constraint, x, y)
        IO.inspect(constraints_to_consider_from_x, label: :constraints_to_consider_from_x)
        {csp, constraints_to_consider_from_y} = enforce_arc_consistency(csp, constraint, y, x)
        IO.inspect(constraints_to_consider_from_y, label: :constraints_to_consider_from_y)

        constraints =
          Enum.uniq(rest ++ constraints_to_consider_from_x ++ constraints_to_consider_from_y)

        solve(csp, constraints)

      k_ary when is_list(k_ary) ->
        raise ArgumentError, "#{length(k_ary)}-ary constraints are not yet supported!"
    end
  end

  def enforce_arc_consistency(csp, constraint, x, y) do
    IO.inspect({x, y}, label: :enforce_arc_consistency)

    x_original_domain = Map.fetch!(csp.domains, x)
    y_original_domain = Map.fetch!(csp.domains, y)

    x_reduced_domain =
      Enum.filter(x_original_domain, fn x_value ->
        Enum.any?(y_original_domain, fn y_value ->
          Constraint.satisfies?(constraint, %{x => x_value, y => y_value})
        end)
      end)

    if length(x_reduced_domain) < length(x_original_domain) do
      csp = %{csp | domains: Map.put(csp.domains, x, x_reduced_domain)}

      dependent_constraints =
        Csp.constraints_on(csp, x)
        |> List.delete(constraint)

      {csp, dependent_constraints}
    else
      {csp, []}
    end
  end

  @spec analyze(Csp.t()) :: Csp.solver_status()
  def analyze(csp) do
    Enum.reduce_while(csp.domains, :solved, fn {_variable, domain}, status ->
      case length(domain) do
        0 -> {:halt, :no_solution}
        1 -> {:cont, status}
        _ -> {:halt, :reduced}
      end
    end)
  end
end
