defprotocol CSP.Constraint do
  @type t :: any

  @spec arguments(t) :: [CSP.variable()]
  def arguments(constraint)

  @spec satisfies?(t, CSP.assignment()) :: boolean()
  def satisfies?(constraint, assignment)
end

defimpl CSP.Constraint, for: Tuple do
  @type t :: {arguments :: [CSP.variable()], test_fun :: (any -> boolean)}

  @spec arguments(t) :: [CSP.variable()]
  def arguments({arguments, _test_fun}) when is_list(arguments), do: arguments

  @spec satisfies?(t, CSP.assignment()) :: boolean()
  def satisfies?({arguments, test_fun}, assignment) do
    actual_arguments = Enum.map(arguments, &Map.fetch!(assignment, &1))

    apply(test_fun, actual_arguments)
  end
end
