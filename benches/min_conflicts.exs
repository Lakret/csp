alias Csp.Problems

Benchee.run(
  %{
    # min_conflicts: fn csp ->
    #   {:solved, _solution} = Csp.solve(csp, method: :min_conflicts, tabu_depth: nil, optimize_initial_state: false)
    # end,
    # min_conflicts_optimize_initial_state: fn csp ->
    #   {:solved, _solution} = Csp.solve(csp, method: :min_conflicts, tabu_depth: nil, optimize_initial_state: true)
    # end,
    min_conflicts_tabu_1: fn csp ->
      {:solved, _solution} = Csp.solve(csp, method: :min_conflicts, tabu_depth: 1, optimize_initial_state: false)
    end,
    min_conflicts_tabu_2: fn csp ->
      {:solved, _solution} = Csp.solve(csp, method: :min_conflicts, tabu_depth: 2, optimize_initial_state: false)
    end,
    min_conflicts_tabu_5: fn csp ->
      {:solved, _solution} = Csp.solve(csp, method: :min_conflicts, tabu_depth: 5, optimize_initial_state: false)
    end,
    min_conflicts_tabu_10: fn csp ->
      {:solved, _solution} = Csp.solve(csp, method: :min_conflicts, tabu_depth: 10, optimize_initial_state: false)
    end,
    min_conflicts_tabu_10_optimize_initial_state: fn csp ->
      {:solved, _solution} = Csp.solve(csp, method: :min_conflicts, tabu_depth: 10, optimize_initial_state: true)
    end,
    min_conflicts_tabu_20: fn csp ->
      {:solved, _solution} = Csp.solve(csp, method: :min_conflicts, tabu_depth: 20, optimize_initial_state: false)
    end,
    min_conflicts_tabu_20_optimize_initial_state: fn csp ->
      {:solved, _solution} = Csp.solve(csp, method: :min_conflicts, tabu_depth: 20, optimize_initial_state: true)
    end
  },
  inputs: %{
    "20 Queens" => Problems.nqueens(20),
    "40 Queens" => Problems.nqueens(40)
  },
  formatters: [
    Benchee.Formatters.HTML,
    Benchee.Formatters.Console
  ]
)
