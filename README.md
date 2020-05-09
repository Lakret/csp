# Constraint Satisfaction

This is a basic implementation of constraint satisfaction problem solver algorithms and some example problems in Elixir.

It accompanies [this Twitch stream](https://www.twitch.tv/videos/572863390).

You can test it by building and running an escript:

```bash
mix deps.get
MIX_ENV=prod mix escript.build
./csp
```

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

Once you have a CSP definition, you can solve / reduce the domains of variables via `AC3` algorithm:

```elixir
Csp.AC3.solve(csp)
```

or run backtracking search on the problem (check out the `Csp.Searcher` docs for all available options):

```elixir
Csp.Searcher.backtrack(csp)
```

## Currently provided test problems

- N Queens
- Map coloring
- Sudoku (taken [from here](https://en.wikipedia.org/wiki/Sudoku))
- Squares problem

## Currently implemented solvers

- AC-3
- simple backtracking search (supports AC-3 preprocessing and interlocked runs, and `variable_selector` strategies:
naïve, minimum remaining values, and custom)
- brute-force search (used for performance comparisons with backtracking; don't use it in real code!)

## Future plans

- Literal constraints (e.g., `{[:x, :y], :distinct}`)
- Parallel solvers
- More examples
- Possibly:
  - PC-2
  - Bounds propagation
