defmodule Problem4 do
  def get_data() do
    {:ok, %HTTPoison.Response{body: body}} =
      HTTPoison.get(
        'https://adventofcode.com/2018/day/4/input',
        [
          IO.puts("\n\nINSERT SESSION HERE\n\n")
        ],
        []
      )

    body
  end

  def parse_data(data) do
    {_, map} =
      data
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_row/1)
      |> Enum.sort(fn [a | _], [b | _] -> a < b end)
      |> Enum.reduce({"", %{}}, &collect_by_guard/2)

    # [{guard, minutes} | _] = map
    #   |> Enum.sort(fn {_, a}, {_, b} -> length(a) > length(b) end)
    #   |> Enum.take(1)
    #
    # {minute, _} = minutes
    #   |> Enum.reduce(%{}, &get_minute_counts/2)
    #   |> Enum.max_by(fn {_, count} -> count end)
    #
    # [id] = Regex.run(~r/\d{1,4}/, guard)
    #
    # String.to_integer(id) * minute

    {guard, {minute, _count}} =
      map
      |> Enum.map(fn {guard, minutes} ->
        {guard, Enum.reduce(minutes, %{}, &get_minute_counts/2)}
      end)
      |> IO.inspect()
      |> Enum.map(fn {guard, counts} -> {guard, get_largest_count(counts)} end)
      |> Enum.max_by(fn {_, {_, count}} -> count end)

    [id] = Regex.run(~r/\d{1,4}/, guard)

    String.to_integer(id) * minute
  end

  def solve(data) do
    data
  end

  def parse_row(row) do
    <<
      _::bytes-size(6),
      month::bytes-size(2),
      _::bytes-size(1),
      day::bytes-size(2),
      _::bytes-size(1),
      hour::bytes-size(2),
      _::bytes-size(1),
      minute::bytes-size(2),
      _::bytes-size(2)
    >> <> message = row

    [
      id: month <> day <> hour <> minute,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      message: message
    ]
  end

  def collect_by_guard(
        [
          id: _,
          month: _,
          day: _,
          hour: _,
          minute: _,
          message: "Guard " <> guard
        ],
        {_, map}
      ) do
    {:ok, map} =
      Map.get_and_update(map, guard, fn
        nil -> {:ok, []}
        x -> {:ok, x}
      end)

    {guard, map}
  end

  def collect_by_guard(
        [
          id: _,
          month: _,
          day: _,
          hour: _,
          minute: minute,
          message: "wakes " <> _
        ],
        {guard, map}
      ) do
    minute = String.to_integer(minute) - 1

    {:ok, map} =
      Map.get_and_update(map, guard, fn
        [x | minutes] -> {:ok, Enum.into(x..minute, []) ++ minutes}
      end)

    {guard, map}
  end

  def collect_by_guard(
        [id: _, month: _, day: _, hour: _, minute: minute, message: "falls " <> _],
        {guard, map}
      ) do
    minute = String.to_integer(minute)

    {:ok, map} =
      Map.get_and_update(map, guard, fn
        minutes -> {:ok, [minute | minutes]}
      end)

    {guard, map}
  end

  def get_minute_counts(minute, []) do
    %{}
  end

  def get_minute_counts(minute, counts) do
    {:ok, counts} =
      Map.get_and_update(counts, minute, fn
        nil -> {:ok, 1}
        total -> {:ok, total + 1}
      end)

    counts
  end

  def get_largest_count(count_map) do
    Enum.max_by(count_map, fn {_, val} -> val end, fn -> {0, 0} end)
  end
end
