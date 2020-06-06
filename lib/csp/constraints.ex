defmodule Csp.Constraints do
  @moduledoc """
  Defines commonly used constraints.
  """
  alias Csp.Constraint

  @doc """
  Creates a list of binary constraints that define that all variables
  in the `variables` list are different.
  """
  @spec all_different_constraints([Csp.variable()]) :: [Constraint.t()]
  def all_different_constraints(variables)

  def all_different_constraints([variable | rest]) do
    constraints =
      Enum.map(rest, fn another_variable ->
        {[variable, another_variable], fn [variable, another_variable] -> variable != another_variable end}
      end)

    constraints ++ all_different_constraints(rest)
  end

  def all_different_constraints([]), do: []
end
