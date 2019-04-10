cmd =
  "curl -X GET -H \"cookie: _ga=GA1.2.49309236.1543508890; _gid=GA1.2.690058700.1544159008; session=53616c7465645f5f619c543729d2b85b15c12e5d428fceb32fa7b4517ad230c6354578df6d2cfd471a0bc03cf8612ee0\" https://adventofcode.com/2018/day/3/input"

defmodule Problem do
  def get_data(port, acc \\ "") do
    receive do
      {^port, {:data, data}} -> get_data(port, acc <> data)
    after
      2000 -> acc
    end
  end

  def parse_row(row) do
    [[id | rest]] =
      Regex.scan(
        ~r/^\#[0-9]{1,4}\ \@\ ([0-9]{1,3})\,([0-9]{1,3})\:\ ([0-9]{1,3})x([0-9]{1,3})$/,
        row
      )

    [x, y, w, h] = Enum.map(rest, &String.to_integer/1)
    {id, x, y, w, h}
  end

  def parse_rows(rows) do
    Enum.map(rows, &parse_row/1)
  end

  def build_point_list({id, x0, y0, w, h}) do
    x1 = x0 + w - 1
    y1 = y0 + h - 1

    List.flatten(
      for x <- x0..x1 do
        for y <- y0..y1, do: {id, x, y}
      end
    )
  end

  def get_claims(square, claims) do
    square
    |> build_point_list()
    |> Enum.reduce(claims, &put_in_claims/2)
  end

  def put_in_claims({id, x, y}, claims) do
    {_, map} =
      Map.get_and_update(claims, {x, y}, fn
        nil -> {:get, id}
        _ -> :pop
      end)

    map
  end

  def in_claims?(claims) do
    fn square ->
      square
      |> build_point_list()
      |> Enum.all?(fn {id, x, y} -> Map.has_key?(claims, {x, y}) end)
    end
  end

  def solve(data) do
    parsed_data =
      data
      |> String.split("\n", trim: true)
      |> parse_rows()

    claims = Enum.reduce(parsed_data, %{}, &get_claims/2)

    Enum.find(parsed_data, in_claims?(claims))
  end
end

Port.open({:spawn, cmd}, [:binary])
|> Problem.get_data()
|> Problem.solve()
|> IO.inspect()
