defmodule Csp.Domains do
  @moduledoc """
  Commonly used domains definitions.
  """

  @doc """
  Defines a domain = [1, 2, ..., 9].
  """
  @spec digit_domain() :: Csp.domain()
  def digit_domain(), do: Enum.to_list(1..9)

  @doc """
  Defines a domain = [0, 1, ..., 9].
  """
  @spec digit_domain_from_zero() :: Csp.domain()
  def digit_domain_from_zero(), do: Enum.to_list(0..9)

  @doc """
  Defines a domain = [true, false].
  """
  @spec boolean_domain() :: Csp.domain()
  def boolean_domain(), do: [true, false]
end
