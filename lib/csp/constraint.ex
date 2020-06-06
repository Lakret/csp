defprotocol Csp.Constraint do
  @moduledoc """
  A constraint protocol: allows defining custom constraints that can be used as part of `Csp` structs.

  ## Provided implementation

  A default impelementation is provided. It implements this protocol for tuple of a list of variables
  (arguments of the constraint), and a function accepting values of those variables
  (in the same order as they are specified in the first element of the tuple)
  returning if the constraint is satisifed by those values of the variables.

  For example, this is a constraint that asserts that variables `:a` and `:b` should not be equal:

  ```
  {[:a, :b], fn a, b -> a != b end}
  ```
  """

  @type t :: any

  @doc """
  Returns a list of variables - arguments that this constraint uses.
  """
  @spec arguments(t) :: [Csp.variable()]
  def arguments(constraint)

  @doc """
  Checks if `constraint` is satisfied by `assignment`.
  """
  @spec satisfies?(t, Csp.assignment()) :: boolean()
  def satisfies?(constraint, assignment)
end

defimpl Csp.Constraint, for: Tuple do
  @type t :: {arguments :: [Csp.variable()], test_fun :: ([any] -> boolean)}

  @spec arguments(t) :: [Csp.variable()]
  def arguments({arguments, _test_fun}) when is_list(arguments), do: arguments

  @spec satisfies?(t, Csp.assignment()) :: boolean()
  def satisfies?({arguments, test_fun}, assignment) do
    actual_arguments = Enum.map(arguments, &Map.fetch!(assignment, &1))

    apply(test_fun, [actual_arguments])
  end
end
