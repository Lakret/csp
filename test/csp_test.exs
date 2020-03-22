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

  test "solver works" do
    csp = Csp.squares_csp()

    {:solved, solution} = Csp.solve(csp)
    assert Csp.solved?(csp, solution)

    {:solved, solutions} = Csp.solve(csp, all: true)
    assert Enum.all?(solutions, &Csp.solved?(csp, &1))

    {:solved, solutions_no_ac3} = Csp.solve(csp, all: true, ac3: false)
    assert Enum.all?(solutions_no_ac3, &Csp.solved?(csp, &1))

    assert solutions == solutions_no_ac3
  end
end
