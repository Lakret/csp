defmodule Csp.Problems do
  @moduledoc """
  Test constraint satisfaction problems.
  """
  import Csp.Domains
  import Csp.Constraints

  alias IO.ANSI

  ################################
  ## Squares
  ################################

  @doc """
  Returns an example Csp struct for the following problem:

  ```
  Y = X ^ 2
  where X, Y are >= 0 and <= `max_value`
  ```

  `max_value` defaults to 9.
  """
  @spec squares(non_neg_integer()) :: Csp.t()
  def squares(max_value \\ 9) do
    domain = Enum.to_list(0..max_value)

    %Csp{
      variables: [:x, :y],
      domains: %{x: domain, y: domain},
      constraints: [
        {[:x, :y], fn [x, y] -> y == x * x end}
      ]
    }
  end

  ################################
  ## Sudoku
  ################################

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
        {[cell], fn [x] -> x == value end}
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

  ################################
  ## Map coloring
  ################################

  @doc """
  Returns an instance of a constraint satisfaction problem
  for [map coloring](https://en.wikipedia.org/wiki/Map_coloring) of Australian states.
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

    constraints =
      Enum.map(inequalities, fn args -> {args, fn [state1, state2] -> state1 != state2 end} end)

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

  ################################
  ## N Queens
  ################################

  @doc """
  Returns an instance of [N-queens problem](https://en.wikipedia.org/wiki/Eight_queens_puzzle)
  for the specified `n`.

  The second argument determines the way we constraint the number of queens that we require to be placed
  on the board:

  - `true` (default) will use 8 row constraints, saying that each row should have exactly one queen
  - `false` will use a global constraint on all cells, saying that we should have exactly `n` queens.

  They are semantically equivalent, but may lead to different performance for solvers. Perhaps counterintuitevely,
  at least for backtracking it's easier to solve the problem with row-based placement constraints
  (even though we have more constraints in total), since we find inconsistencies earlier.

  The variables in the returned CSP are cell coordinates (0-indexed, `{row, column}`);
  domains are boolean (`true` if a queen is placed in the corresponding cell).

  To solve this, we suggest running the following:

  ```elixir
  alias Csp.{Problems, Searcher}

  queens8 = nqueens()
  Searcher.backtrack(queens8, ac3_preprocess: false)
  ```
  """
  @spec nqueens(non_neg_integer()) :: Csp.t()
  def nqueens(n \\ 8, use_row_placement_constraints \\ true) when is_integer(n) do
    cells = for row <- 0..(n - 1), column <- 0..(n - 1), do: {row, column}

    # `true` means that a queen is placed in the corresponding cell;
    # `false` - that the cell is empty
    domains =
      Enum.map(cells, fn cell -> {cell, boolean_domain()} end)
      |> Enum.into(%{})

    # creates the following constraint: if queen is present in `curr_cell`,
    # it shouldn't be present in `another_cell`.
    make_constraint = fn curr_cell, another_cell ->
      {[curr_cell, another_cell],
       fn [cell_occupancy, another_cell_occupancy] ->
         if cell_occupancy, do: !another_cell_occupancy, else: true
       end}
    end

    constraints =
      for {curr_row, curr_column} = curr_cell <- cells do
        [
          # same row constraints
          for column <- 0..(n - 1), column != curr_column do
            make_constraint.(curr_cell, {curr_row, column})
          end,

          # same column constraints
          for row <- 0..(n - 1), row != curr_row do
            make_constraint.(curr_cell, {row, curr_column})
          end,

          # same diagonals constraints
          for(
            row <- 0..(n - 1),
            column <- 0..(n - 1),
            row != curr_row,
            column != curr_column,
            abs(row - curr_row) == abs(column - curr_column),
            do: make_constraint.(curr_cell, {row, column})
          )
        ]
      end
      |> List.flatten()

    constraints =
      if use_row_placement_constraints do
        # replacement for global N queens placement constraint:
        # checks that for each row we have exactly one queen placed
        row_placement_constraints =
          for row <- 0..(n - 1) do
            row_cells = for column <- 0..(n - 1), do: {row, column}
            {row_cells, fn row_occupancy -> Enum.count(row_occupancy, & &1) == 1 end}
          end

        row_placement_constraints ++ constraints
      else
        # global constraint checking that we placed N queens on the board
        n_queens_should_be_placed_constraint =
          {cells, fn cell_values -> Enum.count(cell_values, & &1) == n end}

        [n_queens_should_be_placed_constraint | constraints]
      end

    %Csp{
      variables: cells,
      domains: domains,
      constraints: constraints
    }
  end

  @doc """
  TODO:
  """
  @spec nqueens_via_positions(non_neg_integer()) :: Csp.t()
  def nqueens_via_positions(n \\ 8) when is_integer(n) do
    # Each variable in the number of a row where a queen should be placed
    variables = Enum.to_list(1..n)

    # domain is a 1-indexed column for each of the queens (row number is equal to the variable)
    domains =
      Enum.map(variables, fn row_idx -> {row_idx, Enum.to_list(1..n)} end) |> Enum.into(%{})

    # Constraints
    # - each queen should occupy it's own row - automatically provided by the variables selection

    # - each queen should occupy it's own column - all_different on the variables
    column_constraints = Csp.Constraints.all_different_constraints(variables)

    # - each queen should occupy it's own major (left-to-right) diagonal
    major_diagonal_constraints =
      for row1 <- 1..n, row2 <- 1..n, row1 != row2 do
        {[row1, row2], fn [column1, column2] -> row1 - column1 != row2 - column2 end}
      end

    # - each queen should occupy it's own minor (right-to-left) diagonal
    minor_diagonal_constraints =
      for row1 <- 1..n, row2 <- 1..n, row1 != row2 do
        {[row1, row2], fn [column1, column2] -> row1 + column1 != row2 + column2 end}
      end

    constraints = column_constraints ++ major_diagonal_constraints ++ minor_diagonal_constraints

    %Csp{variables: variables, domains: domains, constraints: constraints}
  end

  def pretty_print_nqueens_via_positions(assignment, n \\ 8) do
    Enum.map(assignment, fn {row, column} -> {{row - 1, column - 1}, true} end)
    |> Enum.into(%{})
    |> pretty_print_nqueens(n)
  end

  @doc """
  Pretty-prints an N Queens problem solution represented as cell assignments.
  """
  @spec pretty_print_nqueens(Csp.assignment(), non_neg_integer()) :: :ok
  def pretty_print_nqueens(assignment, n \\ 8) do
    black_to_white = Stream.cycle([:white, :black])

    for {row, color} <- 0..(n - 1) |> Enum.zip(black_to_white) do
      reverse_color = if color == :black, do: :white, else: :black
      black_to_white = Stream.cycle([color, reverse_color])

      cells =
        for {column, color} <- 0..(n - 1) |> Enum.zip(black_to_white) do
          background =
            if color == :black,
              do: ANSI.light_yellow_background(),
              else: ANSI.default_background()

          if assignment[{row, column}] do
            "#{background} Q #{ANSI.reset()}"
          else
            "#{background}   #{ANSI.reset()}"
          end
        end

      IO.puts(Enum.join(cells))
    end

    :ok
  end
end
