defmodule Problem6 do
  def get_data() do
    {:ok, data} = File.read("/Users/richardpringle/code/advent/inputs/6.txt")

    data
  end

  def parse_data(data) do
    data
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ", "))
    |> Enum.map(&parse_point/1)
  end

  def solve(data) do
    {solve_part_1(data), solve_part_2(data)}
  end

  def solve_part_1(data) do
    max_x = get_max_x(data)
    max_y = get_max_y(data)

    point_list = build_point_list(max_x, max_y)

    bad_points =
      point_list
      |> Stream.with_index()
      |> Enum.filter(filter_with_bounds(max_x, max_y))
      |> Enum.map(&get_index/1)
      |> MapSet.new()

    point_list
    |> Enum.map(get_smallest_distances(data))
    |> Enum.map(fn points -> Enum.map(points, &remove_index/1) end)
    |> Stream.with_index()
    # instead of doing what I did below, I need to find the point in the lists
    # and then filter out those points from the count map
    |> Enum.split_with(fn {_, i} -> !MapSet.member?(bad_points, i) end)
    |> remove_bad_points()
    |> Enum.reduce(%{}, &get_point_count/2)
    |> Enum.max_by(fn {_, count} -> count end)
  end

  def solve_part_2(data) do
    max_x = get_max_x(data)
    max_y = get_max_y(data)

    point_list = build_point_list(max_x, max_y)

    point_list
    |> Enum.map(fn point ->
      data =
        data
        |> Enum.map(fn x -> get_distance(point, x) end)
        |> Enum.reduce(&Kernel.+/2)

      {point, data}
    end)
    |> Enum.filter(fn {_, x} -> x < 10000 end)
    |> length
  end

  def remove_bad_points({good, bad}) do
    bad_set =
      bad
      |> Enum.map(&remove_index/1)
      |> Enum.filter(&has_one_element?/1)
      |> Enum.reduce(MapSet.new(), fn [point], set -> MapSet.put(set, point) end)

    good
    |> Enum.map(&remove_index/1)
    |> Enum.filter(&has_one_element?/1)
    |> Enum.filter(fn [point] -> !MapSet.member?(bad_set, point) end)
    |> Enum.map(fn [point] -> point end)
  end

  def remove_index({x, _i}), do: x
  def get_index({_, i}), do: i

  def get_point_count(point, counts) do
    {:ok, counts} =
      Map.get_and_update(counts, point, fn
        nil -> {:ok, 1}
        count -> {:ok, count + 1}
      end)

    counts
  end

  def is_smaller({x1, y1}, {x2, y2}) do
    if x1 === x2 do
      y1 < y2
    else
      x1 < x2
    end
  end

  def get_max_x(data) do
    {x, _} = Enum.max_by(data, fn {x, _} -> x end)
    x
  end

  def get_max_y(data) do
    {_, y} = Enum.max_by(data, fn {_, y} -> y end)
    y
  end

  def build_point_list(max_x, max_y) do
    Enum.flat_map(0..max_x, fn x ->
      Enum.map(0..max_y, fn y -> {x, y} end)
    end)
  end

  # for each element in point_list, I need to generate a new list
  # of smallest distances with the correspoding index of the points tuple
  # when the length of the list is 1, I need to return that index
  # when the length of the list is greater than 1, I need to return nil
  # then, I need to find the index that appears the most

  def get_smallest_distances(data) do
    fn point ->
      Enum.reduce(data, [], fn
        x, [] ->
          [{x, get_distance(x, point)}]

        x, [{_, smallest} | _] = list ->
          dist = get_distance(point, x)

          cond do
            dist < smallest -> [{x, dist}]
            dist === smallest -> [{x, dist} | list]
            true -> list
          end
      end)
    end
  end

  def get_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  def parse_point([x | [y | []]]) do
    {String.to_integer(x), String.to_integer(y)}
  end

  def filter_with_bounds(x, y) do
    fn
      {{0, _}, _} -> true
      {{^x, _}, _} -> true
      {{_, 0}, _} -> true
      {{_, ^y}, _} -> true
      _ -> false
    end
  end

  def has_one_element?([_el]), do: true
  def has_one_element?(_), do: false
end
