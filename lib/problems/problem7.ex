defmodule Problem7 do
  def get_data() do
    {:ok, data} = File.read("/Users/richardpringle/code/advent/inputs/7.txt")

    data
  end

  def parse_data(data) do
    data
    |> String.split("\n", trim: true)
    |> Enum.map(&get_steps/1)
    |> Enum.take(3)
    |> IO.inspect()
  end

  def solve(data) do
    {solve_part_1(data), solve_part_2(data)}
  end

  def solve_part_1(data) do
    build_list(data)
  end

  def solve_part_2(_data) do
    nil
  end

  def get_steps(x) do
    [_, a, b] = Regex.run(~r/Step ([A-Z]) must be finished before step ([A-Z]) can begin./, x)

    {String.to_charlist(a), String.to_charlist(b)}
  end

  def build_list(data) do
    build_list(data, [])
  end

  def build_list([], acc) do
    Enum.reverse(acc)
  end

  def build_list([first | rest], acc) do
    build_list(rest, join(acc, first))
  end

  def join([], {a, b}) do
    b ++ a
  end

  def join(list, {a, b}) do
    i = Enum.find_index(list, fn x -> x === a end) || 0

    {start, rest} = Enum.split(list, i)

    start = Enum.sort(b ++ start, &(&1 > &2))

    start ++ rest
  end
end
