defmodule Bowling.Scorecard.Score do
  @moduledoc """
  Calculate the score for each frame of a game of bowling.

  Note that what this means is that some frames will not result in an
  updated score - if on a strike for example, the score cannot be
  recalculated until a further two balls have been thrown. In that
  case, the score for that frame will not update. But after the next two
  rolls, that frame (as well as the next frame) will have their scores updated.

  This allows for a data structure that maps one-to-one to the
  standard _visual_ scorecard used in physical bowling games.
  """

  @doc """
  Rebuild a player's scorecard after a frame.
  Given a map of `%{frame => [roll]}` representing the roll history
  up to the just-played frame, return a map of %{ frame => score}
  representing the frame scores up to that point.
  """
  @spec generate(%{number => [number]}) :: %{number => number}
  def generate(rolls) do
    rolls
    |> Enum.map(fn {frame, _} -> {frame, score_up_to(frame, rolls)} end)
    |> Enum.into(%{})
  end

  @doc """
  Given a frame number and a map of `%{ frame => [roll]}` representing the
  current roll history, calculate the score up to that frame. Setup for the
  `calculate_score` function, which grabs all rolls up to the requested frame
  _plus_ the next two balls, _if_ they have been played.

    iex> score_up_to(2, %{1 => [3, 4], 2 => [10]})
    7

    iex> score_up_to(3, %{1 => [3, 4], 2 => [10], 3 => [5, 4]})
    35
  """
  defp score_up_to(frame, roll_history) do
    {rolls_to_score, additional_rolls} = Map.split(roll_history, 1..frame)
    rolls = flat_map_values(rolls_to_score)
    extra = Enum.slice(flat_map_values(additional_rolls), 0, 2)

    calculate_score(rolls, extra)
  end

  @doc """
  Given a list of rolls up to the just-completed frame, calculate the
  score up until that frame. It accepts a second parameter, `extra`, which
  should be an array of length 0..2 describing the frames ahead of the
  currently calculated one. This is what allows the running score to be
  calculated whilst the game is in progress: If all frame scores are
  recalculated at the end of each frame, the scores will change as more balls
  are rolled, correctly updating the scorecard.

    iex> calculate_score([3, 4, 10], [])
    7

    iex> calculate_score([3, 4, 10], [1, 2])
    20

    iex> calculate_score([3, 4, 10, 5, 6, 10, 10, 0, 5], [])
    79
  """
  # Initialise with accumulator on 0 to ensure no score for unstarted game:
  defp calculate_score(rolls, extra, acc \\ 0)

  # If final available frame is a spare/strike, cannot calculate until
  # further rolls. Those rolls may be available, so check first:
  defp calculate_score([10], [x, y], acc), do: acc + 10 + x + y
  defp calculate_score([10], [], acc), do: acc

  defp calculate_score([10, x], [y|_rest] = extra, acc), do: calculate_score([x], extra, acc + 10 + x + y)
  defp calculate_score([10, _x], [], acc), do: acc

  defp calculate_score([x, y], [z|_rest], acc) when x + y == 10, do: acc + 10 + z
  defp calculate_score([x, y], [], acc) when x + y == 10, do: acc

  defp calculate_score([x, y], _extra, acc), do: acc + x + y

  # Strike adds next two rolls:
  defp calculate_score([10, x, y|rest], extra, acc) do
    calculate_score([x, y|rest], extra, acc + 10 + x + y)
  end

  # Spare adds next roll:
  defp calculate_score([x, y, z|rest], extra, acc) when x + y == 10 do
    calculate_score([z|rest], extra, acc + 10 + z)
  end

  # Open frame just adds current values:
  defp calculate_score([x, y|rest], extra, acc) do
     calculate_score(rest, extra, acc + x + y)
  end

  @doc """
  Take a map with array values, turn them into a single flattened list.
  """
  defp flat_map_values(map) do
    map
    |> Map.values()
    |> Enum.flat_map(&(&1))
  end
end
