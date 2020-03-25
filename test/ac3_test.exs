defmodule Csp.AC3Test do
  use ExUnit.Case

  alias Csp.AC3
  alias Csp.Problems

  test "node consistency is enforced" do
    digit_domain = Enum.to_list(0..9)

    csp = %Csp{
      variables: [:x, :y],
      domains: %{
        x: digit_domain,
        y: digit_domain
      },
      constraints: [
        {[:x], fn x -> x <= 7 end},
        {[:y], fn y -> y > 3 end}
      ]
    }

    {:reduced, reduced_csp} = AC3.solve(csp)

    assert reduced_csp.domains == %{
             x: [0, 1, 2, 3, 4, 5, 6, 7],
             y: [4, 5, 6, 7, 8, 9]
           }

    assert reduced_csp.variables == csp.variables
    assert reduced_csp.constraints == csp.constraints
  end

  test "arc consistency is enforced" do
    csp = Problems.squares_csp()

    {:reduced, reduced_csp} = AC3.solve(csp)

    assert reduced_csp.domains == %{
             x: [0, 1, 2, 3],
             y: [0, 1, 4, 9]
           }

    assert reduced_csp.variables == csp.variables
    assert reduced_csp.constraints == csp.constraints
  end
end
