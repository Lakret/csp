# NIF for Elixir.CSP.NIF

## Compiling on macOS

Add this text to `native/csp_nif/.cargo/config` file:

```
[target.x86_64-apple-darwin]
rustflags = [
  "-C", "link-arg=-undefined",
  "-C", "link-arg=dynamic_lookup",
]
```

## To build the NIF module:

- Make sure your projects `mix.exs` has the `:rustler` compiler listed in the `project` function: `compilers: [:rustler] ++ Mix.compilers()` If there already is a `:compilers` list, you should append `:rustler` to it.
- Add your crate to the `rustler_crates` attribute in the `project function. [See here](https://hexdocs.pm/rustler/basics.html#crate-configuration).
- Your NIF will now build along with your project.

## To load the NIF:

```elixir
defmodule CSP.NIF do
    use Rustler, otp_app: <otp-app>, crate: "csp_nif"

    # When your NIF is loaded, it will override this function.
    def add(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
end
```

## Examples

[This](https://github.com/hansihe/NifIo) is a complete example of a NIF written in Rust.
