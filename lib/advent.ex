defmodule Advent do
  @moduledoc """
  Documentation for Advent.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Advent.hello()
      :world

  """
  def hello do
    :world
  end

  def problem(num \\ "") do
    module = String.to_atom("Elixir.Problem" <> num)

    module.get_data()
    |> module.parse_data()
    |> module.solve()
  end
end
