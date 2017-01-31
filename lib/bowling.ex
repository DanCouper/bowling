defmodule Bowling do
  defstruct [frame: 0, frame_roll: 1, roll_history: %{}, pins: 10]

  @doc """
    Creates a new game of bowling that can be used to store the results of
    the game
    NOTE using an Agent instead of a Map. This means the
    test suite has been modified to an extent - to make
    it work with minimal modification, `start\1` returns
    the `game` PID to be passed into the `roll` and `score`
    functions.
  """
  @spec start() :: any
  def start do
    {:ok, game} = Agent.start_link(fn -> %Bowling{frame: 1} end)
    game
  end

  @doc """
    Records the number of pins knocked down on a single roll. Returns `:ok`
    unless there is something wrong with the given number of pins, in which
    case it returns a helpful message.
  """
  @spec roll(any, integer) :: any | String.t
  def roll(_, roll) when roll < 0 or roll > 10 do
    { :error, "Pins must have a value from 0 to 10" }
  end

  def roll(game, roll) do
    # Grab current state to allow pattern matches
    state = Agent.get(game, &(&1))
    roll_update(game, state, roll)
  end

  @doc """
    Returns the score of a given game of bowling if the game is complete.
    If the game isn't complete, it returns a helpful message.
  """
  @spec score(any) :: integer | String.t
  def score(game) do
    state = Agent.get(game, &(&1))

    # NOTE score is calculated _after_ the final frame (so at frame 11).
    # TODO calculate a running score and have that in the game state.
    cond do
      state.frame < 11 ->
        { :error, "Score cannot be taken until the end of the game" }
      state.frame == 11 ->
        calculate_score(state.roll_history)
      state.frame > 11 ->
        {:error, "Invalid game: too many frames"}
    end
  end

  def calculate_score(rolls) do
    rolls
    |> Map.values
    |> BowlingScorer.running_score
    |> Enum.reverse
    |> hd
  end

  # ---------------------------------------------------------------------------

  # Impossible condition (somehow the player's roll has managed to knock down
  # more pins than actually present in lane, which seems contrived)
  def roll_update(_game, %{pins: pins}, roll) when roll > pins do
    { :error, "Pin count exceeds pins on the lane" }
  end

  # Stop adding to the state once game finished. Once it is finished,
  # if the rolls continue, can check frame and error.
  # NOTE again this seems to be contrived; it should be assumed a player
  # will not throw more balls because it isn't logical to do so: this
  # _should_ just noop.
  def roll_update(game, %{frame: frame}, _roll) when frame > 10 do
    Agent.update(game, &(%{&1 | frame: frame + 1}))
  end

  # Strike in last frame, allows for two more strikes
  def roll_update(game, %{frame: 10, frame_roll: frame_roll, roll_history: roll_history}, 10) when frame_roll < 3 do
    updated_history = Map.update(roll_history, 10, [10], &(&1 ++ [10]))
    Agent.update(game, &(%{&1 | frame_roll: frame_roll + 1, pins: 10, roll_history: updated_history }))
  end

  # Strike in first ball of last frame; allows two more balls.
  def roll_update(game, %{frame: 10, frame_roll: 2, pins: pins, roll_history: %{10 => [10]} = roll_history}, roll) do
    updated_history = Map.update(roll_history, 10, [roll], &(&1 ++ [roll]))
    Agent.update(game, &(%{&1 | frame_roll: 3, pins: pins - roll, roll_history: updated_history }))
  end

  # Spare in second ball of last frame.
  def roll_update(game, %{frame: 10, frame_roll: 2, pins: pins, roll_history: roll_history}, roll) when pins - roll == 0 do
    updated_history = Map.update(roll_history, 10, [roll], &(&1 ++ [roll]))
    Agent.update(game, &(%{&1 | frame_roll: 3, pins: 10, roll_history: updated_history }))
  end

  # Strike, just immediately go onto next frame
  def roll_update(game, %{frame: frame, roll_history: roll_history}, 10) do
    updated_history = Map.update(roll_history, frame, [10], &(&1 ++ [10]))
    Agent.update(game, &(%{&1 | frame: frame + 1, frame_roll: 1, pins: 10, roll_history: updated_history }))
  end

  # First ball of frame.
  def roll_update(game, %{frame: frame, frame_roll: 1, pins: pins, roll_history: roll_history}, roll) do
    updated_history = Map.put(roll_history, frame, [roll])
    Agent.update(game, &(%{&1 | frame_roll: 2, pins: pins - roll, roll_history: updated_history}))
  end

  # Second/third ball of frame.
  def roll_update(game, %{frame: frame, roll_history: roll_history}, roll) do
    updated_history = Map.update!(roll_history, frame, &(&1 ++ [roll]))
    Agent.update(game, &(%{&1 | frame: frame + 1, frame_roll: 1, pins: 10, roll_history: updated_history}))
  end



  @doc """
  NOTE: testing function; I am using an Agent, rather than a map,
  to hold state. As a result, the`roll_reduce` function being used
  in the tests won't work, as it tries to reduce an agent.
  """
  def roll_reduce(game, rolls) do
    Enum.each(rolls, fn roll -> Bowling.roll(game, roll) end)
  end
end
