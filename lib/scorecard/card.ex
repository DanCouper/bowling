defmodule Bowling.Scorecard.Card do
  @moduledoc """
  Creates a scorecard for a single player in a single game. This contains the
  majority of the information about the game as it relates to a player, and
  a collection of scorecards should provide almost everything needed to
  generate a working UI.
  """
  alias Bowling.Scorecard.Score, as: Score
  alias Bowling.Scorecard.Card, as: Card

  @lint {Credo.Check.Readability.MaxLineLength, false}
  defstruct [frame: 0, frame_roll: 1, pins: 10, game_id: nil, player_id: nil, rolls: %{}, scores: %{}]

  @doc """
  Creates a new player's scorecard for a game of bowling.
  """
  @spec create(any, any) :: any
  @lint {Credo.Check.Readability.MaxLineLength, false}
  def create(game_id, player_id) do
    Agent.start_link(fn -> %Card{game_id: game_id, player_id: player_id, frame: 1} end)
  end

  @doc """
  Records the number of pins knocked down on a single roll.
  """
  @spec roll(any, integer) :: any
  def roll(game, roll) do
    Agent.update(game, &roll_update(&1, roll))
  end

  @doc """
  State updater function. Handles the various edge cases. Updates pin counts,
  frames, which roll of the frame is happening, what to do with strikes/spares.
  Note that in every update that iterates the frame number, the score is
  recalculated.
  """
  # Strike in last frame, allows for two more strikes
  @lint {Credo.Check.Readability.MaxLineLength, false}
  defp roll_update(%{frame: 10, frame_roll: frame_roll, rolls: rolls} = state, 10) when frame_roll < 3 do
    updated_rolls = Map.update(rolls, 10, [10], &(&1 ++ [10]))
    %{state | frame_roll: frame_roll + 1, pins: 10, rolls: updated_rolls}
  end

  # Strike in first ball of last frame; allows two more balls.
  @lint {Credo.Check.Readability.MaxLineLength, false}
  defp roll_update(%{frame: 10, frame_roll: 2, pins: pins, rolls: %{10 => [10]} = rolls} = state, roll) do
    updated_rolls = Map.update(rolls, 10, [roll], &(&1 ++ [roll]))
    %{state | frame_roll: 3, pins: pins - roll, rolls: updated_rolls}
  end

  # Spare in second ball of last frame.
  @lint {Credo.Check.Readability.MaxLineLength, false}
  defp roll_update(%{frame: 10, frame_roll: 2, pins: pins, rolls: rolls} = state, roll) when pins - roll == 0 do
    updated_rolls = Map.update(rolls, 10, [roll], &(&1 ++ [roll]))
    %{state | frame_roll: 3, pins: 10, rolls: updated_rolls}
  end

  # Strike, just immediately go onto next frame
  @lint {Credo.Check.Readability.MaxLineLength, false}
  defp roll_update(%{frame: frame, rolls: rolls} = state, 10) do
    updated_rolls = Map.update(rolls, frame, [10], &(&1 ++ [10]))
    updated_scores = Score.generate(updated_rolls)
    %{state | frame: frame + 1, frame_roll: 1, pins: 10, rolls: updated_rolls, scores: updated_scores}
  end

  # First ball of frame.
  @lint {Credo.Check.Readability.MaxLineLength, false}
  defp roll_update(%{frame: frame, frame_roll: 1, pins: pins, rolls: rolls} = state, roll) do
    updated_rolls = Map.put(rolls, frame, [roll])
    %{state | frame_roll: 2, pins: pins - roll, rolls: updated_rolls}
  end

  # Second/third ball of frame.
  @lint {Credo.Check.Readability.MaxLineLength, false}
  defp roll_update(%{frame: frame, rolls: rolls} = state, roll) do
    updated_rolls = Map.update!(rolls, frame, &(&1 ++ [roll]))
    updated_scores = Score.generate(updated_rolls)
    %{state | frame: frame + 1, frame_roll: 1, pins: 10, rolls: updated_rolls, scores: updated_scores}
  end
end
