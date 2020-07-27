alias Csp.Problems

Benchee.run(
  %{
    # min_conflicts: fn csp ->
    #   {:solved, _solution} = Csp.solve(csp, method: :min_conflicts, tabu_depth: nil, optimize_initial_state: false)
    # end,
    # min_conflicts_optimize_initial_state: fn csp ->
    #   {:solved, _solution} = Csp.solve(csp, method: :min_conflicts, tabu_depth: nil, optimize_initial_state: true)
    # end,
    # min_conflicts_tabu_1: fn csp ->
    #   {:solved, _solution} = Csp.solve(csp, method: :min_conflicts, tabu_depth: 1, optimize_initial_state: false)
    # end,
    # min_conflicts_tabu_2: fn csp ->
    #   {:solved, _solution} = Csp.solve(csp, method: :min_conflicts, tabu_depth: 2, optimize_initial_state: false)
    # end,
    # min_conflicts_tabu_5: fn csp ->
    #   {:solved, _solution} = Csp.solve(csp, method: :min_conflicts, tabu_depth: 5, optimize_initial_state: false)
    # end,
    min_conflicts_tabu_10: fn csp ->
      {:solved, _solution} = Csp.solve(csp, method: :min_conflicts, tabu_depth: 10, optimize_initial_state: false)
    end,
    # min_conflicts_tabu_10_optimize_initial_state: fn csp ->
    #   {:solved, _solution} = Csp.solve(csp, method: :min_conflicts, tabu_depth: 10, optimize_initial_state: true)
    # end,
    min_conflicts_tabu_20: fn csp ->
      {:solved, _solution} = Csp.solve(csp, method: :min_conflicts, tabu_depth: 20, optimize_initial_state: false)
    end
    # min_conflicts_tabu_20_optimize_initial_state: fn csp ->
    #   {:solved, _solution} = Csp.solve(csp, method: :min_conflicts, tabu_depth: 20, optimize_initial_state: true)
    # end
  },
  inputs: %{
    "20 Queens" => Problems.nqueens(20),
    "32 Queens" => Problems.nqueens(32)
  },
  formatters: [
    Benchee.Formatters.Console,
    {Benchee.Formatters.CSV, file: "min_conflicts_benchmark.csv"}
  ]
)

# alias Csp.Problems
# csp = Problems.nqueens(20)
# csp = Problems.nqueens(32)
# csp = Problems.nqueens(64)

{time, solution} =
  :timer.tc(fn ->
    Csp.solve(csp, method: :min_conflicts, tabu_depth: 20, optimize_initial_state: true)
  end)

times = [18_661_874, 11_259_981]

{time, solution} =
  :timer.tc(fn ->
    Csp.solve(csp, method: :min_conflicts, tabu_depth: 10, optimize_initial_state: true)
  end)

times = [18_661_874, 11_259_981]

{time, solution} =
  :timer.tc(fn ->
    Csp.solve(csp, method: :min_conflicts, tabu_depth: 20, optimize_initial_state: true, threads: 4)
  end)

# {time, solution} =
#   :timer.tc(fn ->
#     Csp.solve(csp, method: :min_conflicts, tabu_depth: 10, optimize_initial_state: true)
#   end)
# Enum.sum(times) / 3
# times = [993_860, 1_690_015, 1_315_794]
# # (1.3 seconds on average)

# {time, solution} =
#   :timer.tc(fn ->
#     Csp.solve(csp, method: :min_conflicts, tabu_depth: 10, optimize_initial_state: false)
#   end)
# times = [1_967_647, 2_338_976, 1_402_931]
# Enum.sum(times) / 3
# # (1.9 seconds on average)

# {time, solution} =
#   :timer.tc(fn ->
#     Csp.solve(csp, method: :min_conflicts, tabu_depth: 10, optimize_initial_state: true)
#   end)
# times = [971_727, 1_851_814, 1_322_502]
# Enum.sum(times) / 3
# # (1.4 seconds on average)
