defmodule ConstraintsTest do
  use ExUnit.Case

  alias Csp.Constraints

  test "Constraints.all_different_constraints/1 works" do
    constraints = Constraints.all_different_constraints([0, 1, 2])
    assert constraints == [{[0, 1], &!=/2}, {[0, 2], &!=/2}, {[1, 2], &!=/2}]

    assert Constraints.all_different_constraints([]) == []
    assert Constraints.all_different_constraints([1]) == []
  end
end
