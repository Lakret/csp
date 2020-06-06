# Constraint Satisfaction

This is a basic implementation of constraint satisfaction problem solver algorithms and some example problems in Elixir.

It has an accompanying [YouTube video](https://www.youtube.com/watch?v=ao1CO8_V5do) and [Twitch stream](https://www.twitch.tv/videos/572863390).

## Installation

The package can be installed by adding `decidex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:csp, "~> 0.1"}
  ]
end
```

Docs are available [on Hex.pm](https://hexdocs.pm/csp).

The library is dually licensed under Apache 2 or MIT (choose whichever you prefer).

## Usage

Constraints are modelled as normal Elixir structs, with the following structure:

```elixir
%Csp{
  # list of variable ids; could be any Elixir terms that are hashable
  variables: [:x, :y, ...],
  # domains map each variable to a list of all possible values it can be assigned to
  domains: %{
    x: [1, 2, 3, 4],
    y: [true, false],
    ...
  },
  # constraints are specified as a list of tuples `{arguments_list, predicate}`.
  # `arguments_list` is a list of variables participating in the constraint.
  # `predicate` is an unary function taking a list of those variables values (in the same order)
  # and returning `true` or `false` signifying if the constraint was satisfied
  constraints: %{
    # the most common kind is inequality constraint, e.g. to specify that x != y:
    {[:x, :y], fn [x, y] -> x != y end},
    ...
  }
}
```

You can also use helpers from `Csp.Constraints` and `Csp.Domains` modules to simplify creating CSP definitions.

Once you have a CSP definition, you can solve it:

```elixir
Csp.solve(csp)
```

You can specify different methods, for example, min-conflicts, and pass parameters to them, e.g.:

```elixir
Csp.solve(csp, method: :min_conflicts, tabu_depth: 10)
```

Additionally, you can check this repo out, build the provided escript, and play with the CLI interface for the example problems:

```bash
mix deps.get
MIX_ENV=prod mix escript.build
./csp
```

## Currently implemented solvers

- backtracking search (supports AC-3 inference, and `variable_selector` strategies: naïve, minimum remaining values, and custom)
- min-conflicts with tabu search
- AC-3 with backtracking to extract results
- brute-force search (used for performance comparisons with backtracking; don't use it in the real code!)

## Currently provided test problems

- N Queens (with 3 different representations)
- Map coloring
- Sudoku (taken [from here](https://en.wikipedia.org/wiki/Sudoku))
- Squares problem

## Future plans

- Literal constraints (e.g., `{[:x, :y], :distinct}`)
- Parallel solvers
- More examples
- Possibly:
  - PC-2
  - Bounds propagation
