defmodule BowlingScorerTest do
  use ExUnit.Case

  @tag :pending
  test "Calculates running scores for a full game" do
    rolls = [[10], [10], [1, 2], [8, 1], [2, 6], [4, 2], [0, 0], [10], [10], [10, 6, 4]]
    assert BowlingScorer.running_score(rolls) == [21, 34, 37, 46, 54, 60, 60, 90, 116, 136]
  end

  @tag :pending
  test "Calculates running scores for a full perfect game" do
    rolls = [[10], [10], [10], [10], [10], [10], [10], [10], [10], [10, 10, 10]]
    assert BowlingScorer.running_score(rolls) == [30, 60, 90, 120, 150, 180, 210, 240, 270, 300]
  end

  # test "Does not calculate score on first roll" do
  #   assert BowlingScorer.running_score([[0]]) == :noop
  # end
end
