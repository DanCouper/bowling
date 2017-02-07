defmodule Bowling.Scorecard.RunningScoreTest do
  use ExUnit.Case
  alias Bowling.Scorecard.RunningScore, as: RunningScore

  test "calculates running scores for a non-scoring game" do
    input  = %{
      1 => [0,0],
      2 => [0,0],
      3 => [0,0],
      4 => [0,0],
      5 => [0,0],
      6 => [0,0],
      7 => [0,0],
      8 => [0,0],
      9 => [0,0],
      10 => [0,0]
    }

    output = %{
      1 => 0,
      2 => 0,
      3 => 0,
      4 => 0,
      5 => 0,
      6 => 0,
      7 => 0,
      8 => 0,
      9 => 0,
      10 => 0
    }

    assert RunningScore.generate(input) == output
  end

  test "calculates running scores for a game with no strikes or spares" do
    input  = %{
      1 => [1,4],
      2 => [5,4],
      3 => [1,3],
      4 => [2,6],
      5 => [7,0],
      6 => [0,0],
      7 => [0,9],
      8 => [7,1],
      9 => [4,4],
      10 => [5,4]
    }

    output = %{
      1 => 5,
      2 => 14,
      3 => 18,
      4 => 26,
      5 => 33,
      6 => 33,
      7 => 42,
      8 => 50,
      9 => 58,
      10 => 67
    }

    assert RunningScore.generate(input) == output
  end

  # @tag :pending
  test "calculates running scores for an incomplete game with no strikes or spares" do
    input  = %{
      1 => [4, 5],
      2 => [7, 2],
      3 => [1, 2],
      4 => [8, 1],
      5 => [2, 6],
      6 => [4, 2],
      7 => [0, 0]
    }

    output = %{
      1 => 9,
      2 => 18,
      3 => 21,
      4 => 30,
      5 => 38,
      6 => 44,
      7 => 44
    }

    assert RunningScore.generate(input) == output
  end

  # @tag :pending
  test "calculates running scores for a full game" do
    input  = %{
      1 => [10],
      2 => [10],
      3 => [1, 2],
      4 => [8, 1],
      5 => [2, 6],
      6 => [4, 2],
      7 => [0, 0],
      8 => [10],
      9 => [10],
      10 => [10, 6, 4]
    }

    output = %{
      1 => 21,
      2 => 34,
      3 => 37,
      4 => 46,
      5 => 54,
      6 => 60,
      7 => 60,
      8 => 90,
      9 => 116,
      10 => 136
    }

    assert RunningScore.generate(input) == output
  end

  # @tag :pending
  test "calculates running scores for a full perfect game" do
    input = %{
      1 => [10],
      2 => [10],
      3 => [10],
      4 => [10],
      5 => [10],
      6 => [10],
      7 => [10],
      8 => [10],
      9 => [10],
      10 => [10, 10, 10]
    }

    output = %{
      1 => 30,
      2 => 60,
      3 => 90,
      4 => 120,
      5 => 150,
      6 => 180,
      7 => 210,
      8 => 240,
      9 => 270,
      10 => 300
    }

    assert RunningScore.generate(input) == output
  end

  # @tag :pending
  test "won't increment the score when spare in last calculated frame" do
    input  = %{
      1 => [4, 5],
      2 => [7, 2],
      3 => [1, 9]
    }

    output = %{
      1 => 9,
      2 => 18,
      3 => 18
    }

    assert RunningScore.generate(input) == output
  end

  # @tag :pending
  test "will increment the score in previous frame when in frame after spare" do
    input  = %{
      1 => [4, 5],
      2 => [7, 2],
      3 => [1, 9],
      4 => [5, 1]
    }

    output = %{
      1 => 9,
      2 => 18,
      3 => 33,
      4 => 39
    }

    assert RunningScore.generate(input) == output
  end
end
