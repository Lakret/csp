# Constraint Satisfaction

This is an example implementation of constraint satisfaction problem solver algorithms.

It accompanies [this Twitch stream](https://www.twitch.tv/videos/572863390).

You can test it by building and running an escript:

```bash
mix escript.build
./csp
```

Currently provided test problems:

- Sudoku (taken [from here](https://en.wikipedia.org/wiki/Sudoku))
- Squares problem

Currently implemented solvers:

- AC-3
- brute-force search

**Future plans:** 9 queens, Backtracking, combine Backtracking and AC-3; parallel version; solver UI, Rust module

**Possible:** PC-2
