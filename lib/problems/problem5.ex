defmodule Problem5 do
  def get_data() do
    {:ok, data} = File.read("/Users/richardpringle/code/advent/inputs/5.txt")

    data
  end

  def parse_data(data) do
    data
    |> String.replace("\n", "", global: true)
    |> String.to_charlist()
  end

  def solve(data) do
    part_1 =
      data
      |> Enum.reduce([], &react/2)
      |> length()

    part_2 =
      Enum.into(65..90, [])
      |> Enum.map(strip(data))
      |> Enum.map(fn data -> length(Enum.reduce(data, [], &react/2)) end)
      |> IO.inspect()
      |> Enum.min()

    # part_1
    part_2
  end

  def strip(data) do
    fn char_code ->
      data
      |> Enum.filter(fn char ->
        char !== char_code and char !== char_code + 32
      end)
    end
  end

  def react(x, stack) do
    head = Stack.head(stack)

    if case_change?(head, x) do
      Stack.pop(stack)
    else
      Stack.push(stack, x)
    end
  end

  def case_change?(nil, _), do: false

  def case_change?(head, char) do
    head =
      if head > 96 do
        head - 32
      else
        head + 32
      end

    head === char
  end
end

defmodule Stack do
  def head([]), do: nil
  def head([head | _tail]), do: head

  def push(list, char) do
    [char | list]
  end

  # not your standard pop function but it works
  def pop([_head | tail]) do
    tail
  end
end
