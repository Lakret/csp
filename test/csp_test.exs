defmodule CspTest do
  use ExUnit.Case
  doctest Csp

  test "squares CSP is well-defined" do
    csp = Csp.squares_csp()

    assert Csp.solved?(csp, %{x: 2, y: 4})
    assert !Csp.solved?(csp, %{x: 2, y: 3})
  end

  test "map-coloring CSP is well-defined" do
    csp = Csp.map_coloring_csp()

    assert Csp.solved?(csp, Csp.map_coloring_example_solution())
    assert !Csp.solved?(csp, Csp.map_coloring_wrong_solution())
  end

  test "node consistency is enforced" do
  end
end
