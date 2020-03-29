defmodule ConstraintsTest do
  use ExUnit.Case

  alias Csp.Constraints

  test "Constraints.all_different_constraints/1 works" do
    constraints = Constraints.all_different_constraints([0, 1, 2])
    [{[0, 1], f}, {[0, 2], f}, {[1, 2], f}] = constraints

    assert Constraints.all_different_constraints([]) == []
    assert Constraints.all_different_constraints([1]) == []
  end
end
