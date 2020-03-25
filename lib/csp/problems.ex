defmodule Csp.Problems do
  @moduledoc """
  Test constraint satisfaction problems.
  """
  import Csp.Domains
  import Csp.Constraints

  @doc """
  Returns an example Csp struct for the following problem:

  ```
  Y = X ^ 2
  where X, Y are digits
  ```
  """
  @spec squares() :: Csp.t()
  def squares() do
    %Csp{
      variables: [:x, :y],
      domains: %{x: digit_domain_from_zero(), y: digit_domain_from_zero()},
      constraints: [
        {[:x, :y], fn x, y -> y == x * x end}
      ]
    }
  end

  @type sudoku_cells_map :: %{{row :: 0..8, column :: 0..8} => 1..9}

  @doc """
  Defines a Sudoku puzzle, with `prefilled` map of unary constraints
  for prefilled variables.

  `prefilled` should be a map matching cell coordinates (expressed as
  tuples `{row, column}`, with 0-indexed rows and column) to theire prefilled values.
  """
  @spec sudoku(sudoku_cells_map) :: Csp.t()
  def sudoku(prefilled) do
    variables = for row <- 0..8, column <- 0..8, do: {row, column}
    domains = Enum.map(variables, fn var -> {var, digit_domain()} end) |> Enum.into(%{})

    column_constraints =
      Enum.flat_map(0..8, fn column ->
        variables = for row <- 0..8, do: {row, column}
        all_different_constraints(variables)
      end)

    row_constraints =
      Enum.flat_map(0..8, fn row ->
        variables = for column <- 0..8, do: {row, column}
        all_different_constraints(variables)
      end)

    boxes = for box_row <- 0..2, box_column <- 0..2, do: {box_row, box_column}

    box_constraints =
      Enum.flat_map(boxes, fn {box_row, box_column} ->
        cells =
          for row <- (box_row * 3)..(box_row * 3 + 2),
              column <- (box_column * 3)..(box_column * 3 + 2),
              do: {row, column}

        all_different_constraints(cells)
      end)

    prefilled_constraints =
      Enum.map(prefilled, fn {cell, value} ->
        {[cell], fn x -> x == value end}
      end)

    constraints =
      Enum.uniq(prefilled_constraints ++ column_constraints ++ row_constraints ++ box_constraints)

    %Csp{
      variables: variables,
      domains: domains,
      constraints: constraints
    }
  end

  @doc """
  A cells map of prefilled values from
  an example Sudoku [from Wikipedia](https://en.wikipedia.org/wiki/Sudoku).
  """
  @spec wiki_sudoku_cells_map() :: sudoku_cells_map
  def wiki_sudoku_cells_map() do
    box00 = %{{0, 0} => 5, {0, 1} => 3, {1, 0} => 6, {2, 1} => 9, {2, 2} => 8}
    box01 = %{{0, 4} => 7, {1, 3} => 1, {1, 4} => 9, {1, 5} => 5}
    box02 = %{{2, 7} => 6}
    box10 = %{{3, 0} => 8, {4, 0} => 4, {5, 0} => 7}
    box11 = %{{3, 4} => 6, {4, 3} => 8, {4, 5} => 3, {5, 4} => 2}
    box12 = %{{3, 8} => 3, {4, 8} => 1, {5, 8} => 6}
    box20 = %{{6, 1} => 6}
    box21 = %{{7, 3} => 4, {7, 4} => 1, {7, 5} => 9, {8, 4} => 8}
    box22 = %{{6, 6} => 2, {6, 7} => 8, {7, 8} => 5, {8, 7} => 7, {8, 8} => 9}

    [box00, box01, box02, box10, box11, box12, box20, box21, box22]
    |> Enum.reduce(%{}, &Map.merge/2)
  end

  @doc """
  Returns a CSP corresponding to the example Sudoku
  [from Wikipedia](https://en.wikipedia.org/wiki/Sudoku).
  """
  @spec wiki_sudoku() :: Csp.t()
  def wiki_sudoku() do
    wiki_sudoku_cells_map()
    |> sudoku()
  end

  @doc """
  Pretty prints a prefilled or solved Sudoku
  from `sudoku_cells_map`, mapping cell coordinates to values.
  """
  @spec pretty_print_sudoku(sudoku_cells_map) :: :ok
  def pretty_print_sudoku(sudoku_cells_map) do
    for row <- 0..8 do
      row_string =
        Enum.map(0..8, fn column ->
          cell =
            case sudoku_cells_map[{row, column}] do
              nil -> "  "
              value when is_integer(value) -> " #{value}"
            end

          if column in [2, 5] do
            cell <> "|"
          else
            cell <> " "
          end
        end)
        |> Enum.join("")

      IO.puts(row_string)

      if row in [2, 5] do
        IO.puts("---------------------------")
      end
    end

    :ok
  end

  @doc """
  Returns an instance of a constraint satisfaction problem
  for map coloring of Australia.
  """
  @spec map_coloring() :: Csp.t()
  def map_coloring() do
    states = ~w(WA NT Q NSW V SA T)a
    domains = for state <- states, do: {state, ~w(red green blue)a}, into: %{}

    inequalities = [
      [:SA, :WA],
      [:SA, :NT],
      [:SA, :Q],
      [:SA, :NSW],
      [:SA, :V],
      [:WA, :NT],
      [:NT, :Q],
      [:Q, :NSW],
      [:NSW, :V]
    ]

    constraints = Enum.map(inequalities, fn args -> {args, &!=/2} end)

    %Csp{variables: states, domains: domains, constraints: constraints}
  end

  @doc """
  Returns an example of a correct solution of the map coloring Csp.
  """
  @spec map_coloring_example_solution :: Csp.assignment()
  def map_coloring_example_solution() do
    %{WA: :red, NT: :green, Q: :red, NSW: :green, V: :red, SA: :blue, T: :red}
  end

  @doc """
  Returns an example of a wrong solution of the map coloring Csp.
  """
  @spec map_coloring_wrong_solution :: Csp.assignment()
  def map_coloring_wrong_solution() do
    %{WA: :green, NT: :red, Q: :red, NSW: :green, V: :red, SA: :blue, T: :red}
  end
end
