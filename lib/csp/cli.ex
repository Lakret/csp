defmodule CSP.CLI do
  @moduledoc """
  Command line interface for constraint satisfaction.
  """

  @doc """
  Usage:

  ```
  $ mix escript.build
  $ ./csp --foo='bar baz' --n=4 --enabled
  ```
  """
  def main(args) do
    IO.puts("Let's do some constraint satisfaction.")

    IO.inspect(args, label: :args)

    {parsed, _rest} =
      OptionParser.parse!(args,
        strict: [
          foo: :string,
          n: :integer,
          enabled: :boolean
        ]
      )

    IO.inspect(parsed, label: :parsed)
  end
end
