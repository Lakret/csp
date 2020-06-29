alias Csp.Problems

Benchee.run(
  %{
    backtracking_default: fn csp ->
      {:solved, _solution} = Csp.solve(csp, method: :backtracking, variable_selector: :take_head, ac3: false)
    end
    # backtracking_minimum_remaining_values: fn csp ->
    #   {:solved, _solution} =
    #     Csp.solve(csp, method: :backtracking, variable_selector: :minimum_remaining_values, ac3: false)
    # end
  },
  inputs: %{
    "4 Queens optimal" => Problems.nqueens(4),
    "6 Queens optimal" => Problems.nqueens(6),
    "8 Queens optimal" => Problems.nqueens(8),
    "10 Queens optimal" => Problems.nqueens(10),
    "12 Queens optimal" => Problems.nqueens(12),
    "14 Queens optimal" => Problems.nqueens(14),
    "16 Queens optimal" => Problems.nqueens(16)
    # "4 Queens slower" => Problems.nqueens_slow(4),
    # "8 Queens slower" => Problems.nqueens_slow(8),
    # "10 Queens slower" => Problems.nqueens_slow(10)
  },
  # memory_time: 5,
  formatters: [
    Benchee.Formatters.Console,
    {Benchee.Formatters.CSV, file: "backtracking_benchmark.csv"}
  ]
)
