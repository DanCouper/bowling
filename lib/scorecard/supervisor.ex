defmodule Bowling.Scorecard.Supervisor do
  @moduledoc """
  Allows creation/management of scorecards.

  Once a game has players, one card should be generated for
  each player involved.
  """
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  @spec init(atom) :: any
  def init(:ok) do
    children = [
      worker(Bowling.Scorecard.Card, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  # def new_scorecard(game_id, player_id) do
  #   Supervisor.start_child(Bowling.Scorecard.Supervisor, [game_id, player_id])
  # end
end
