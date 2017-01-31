defmodule BowlingScorer do
  def running_score(rolls, acc \\ [])

  def running_score([], acc) do
    acc
    |> Enum.reverse
    |> Enum.scan(&(&1 + &2))
  end

  def running_score([[a,b]|rest], acc) when a + b < 10 do
    running_score(rest, [a + b|acc])
  end

  def running_score([[a,b],[c|tail]|rest], acc) when a + b == 10 do
    running_score([[c|tail]|rest], [a + b + c|acc])
  end

  def running_score([[10],[a,b|tail]|rest], acc) do
    running_score([[a,b|tail]|rest], [10 + a + b|acc])
  end

  def running_score([[10],[10],[10|tail]|rest], acc) do
    running_score([[10],[10|tail]|rest], [10 + 10 + 10|acc])
  end

  def running_score([[10],[10],[a|tail]|rest], acc) do
    running_score([[10],[a|tail]|rest], [10 + 10 + a|acc])
  end

  def running_score([[10,10,10]], acc), do: running_score([], [10 + 10 + 10|acc])
  def running_score([[10,10,a]], acc), do: running_score([], [10 + 10 + a|acc])
  def running_score([[10,a,b]], acc), do: running_score([], [10 + a + b|acc])
  def running_score([[a,b,c]], acc), do: running_score([], [a + b + c|acc])
end
