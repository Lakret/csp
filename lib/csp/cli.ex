defmodule Csp.CLI do
  @moduledoc """
  Command line interface for constraint satisfaction.
  """
  alias Csp.{Problems, AC3, Searcher}

  @doc """
  Usage:

  ```
  $ mix escript.build
  $ ./csp
  ```
  """
  def main(_args) do
    IO.puts("Let's try out some example constraint satisfaction problems.")

    trial_problem_selection()
  end

  ## Helpers

  defp trial_problem_selection() do
    IO.puts("Select a trial problem (type `1`, `2`, ...), or terminate (type `q`):")
    IO.puts("\t1. Sudoku")
    IO.puts("\t2. Squares")
    IO.puts("\t3. Map coloring")
    IO.puts("\tq. Exit")

    problem = IO.read(:line) |> String.trim()

    if problem != "q" do
      case Integer.parse(problem) do
        {problem, ""} ->
          case problem do
            1 -> trial_sudoku_problem()
            2 -> trial_squares_problem()
            3 -> trial_map_coloring_problem()
          end

        unexpected ->
          IO.puts("Unexpected input: #{unexpected}; restarting.")
          trial_problem_selection()
      end
    else
      IO.puts("Terminating.")
    end
  end

  defp trial_sudoku_problem() do
    original_cells_map = Problems.wiki_sudoku_cells_map()

    IO.puts("\nThis is the input Sudoku puzzle:\n")
    Problems.pretty_print_sudoku(original_cells_map)

    ws_csp = Problems.wiki_sudoku()

    IO.puts(
      "\nCSP definition has #{length(ws_csp.variables)} variables " <>
        "and #{length(ws_csp.constraints)} inequality constraints."
    )

    {time, {:solved, ws_csp_solved}} = :timer.tc(fn -> AC3.solve(ws_csp) end)

    IO.puts("Solved with AC-3 in #{time / 1_000_000} seconds.")

    solution_cells_map =
      ws_csp_solved.domains
      |> Enum.map(fn {cell, [value]} -> {cell, value} end)
      |> Enum.into(%{})

    IO.puts("\nSolution:\n")
    Problems.pretty_print_sudoku(solution_cells_map)
    IO.puts("")

    trial_problem_selection()
  end

  defp trial_squares_problem() do
    IO.puts("\nSelect the max value of x and y (integer between 5 and 1_000_000_000):")

    max_value = IO.read(:line) |> String.trim()
    {max_value, ""} = Integer.parse(max_value)

    IO.puts("\nThis is the input squares puzzle:\n")

    IO.puts(
      "\t>> Find all pairs (x, y), such that y = x * x, \n" <>
        "\t   if x and y are integers between 0 and #{max_value}.\n"
    )

    csp = Problems.squares(max_value)

    IO.puts("Original CSP (note variables' domains!):\n#{inspect(csp)}\n")
    IO.puts("We will need to supplement AC-3 with brute-force search to solve it.")
    IO.puts("Do you want to run AC-3 before doing brute force search? (y/n)")

    run_ac3 = IO.read(:line) |> String.trim()

    if run_ac3 == "y" do
      IO.puts("First, we will reduce the domains of our variables via AC-3.\n")

      {time, {:reduced, csp}} = :timer.tc(fn -> AC3.solve(csp) end)

      IO.puts("AC-3 run took #{time / 1_000_000} seconds, and reduced domains of variables to:\n")
      IO.puts("#{inspect(csp.domains)}\n")

      trial_squares_problem_brute_force_part(csp)
    else
      trial_squares_problem_brute_force_part(csp)
    end
  end

  def trial_squares_problem_brute_force_part(csp) do
    IO.puts("Now we can run brute force search.\n")

    {time, {:solved, solutions}} = :timer.tc(fn -> Searcher.brute_force(csp, all: true) end)

    IO.puts(
      "Brute force search run took #{time / 1_000_000} seconds, " <>
        "and found the following solutions:\n"
    )

    solution_string =
      Enum.map(solutions, fn solution -> "\t#{inspect(solution)}" end) |> Enum.join("\n")

    IO.puts(solution_string)
    IO.puts("")

    trial_problem_selection()
  end

  def trial_map_coloring_problem() do
    IO.puts("Let's solve map coloring problem for Austrialian states with backtracking search.\n")

    csp = Problems.map_coloring()
    IO.puts("CSP is defined like this:\n#{inspect(csp)}\n\n")

    IO.puts("Running backtracking...")
    {time, {:solved, solutions}} = :timer.tc(fn -> Searcher.backtrack(csp, all: true) end)

    IO.puts(
      "Backtracking run took #{time / 1_000_000} seconds, " <>
        "and found the following solutions:\n"
    )

    solution_string =
      Enum.map(solutions, fn solution -> "\t#{inspect(solution)}\n" end) |> Enum.join("")

    IO.puts(solution_string)
    IO.puts("")

    trial_problem_selection()
  end
end
