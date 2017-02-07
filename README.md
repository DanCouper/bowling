# Bowling

Score a bowling game

Bowling is game where players roll a heavy ball to knock down pins arranged in a triangle. Write code to keep track of the score of a game of bowling.

*I am using this as practice for building complete apps/umbrella apps, so starting off leveraging agents to
hold the state of a player's game.*

## Scoring Bowling

The game consists of 10 frames. A frame is composed of one or two ball throws with 10 pins standing at frame initialization. There are three cases for the tabulation of a frame.

* An open frame is where a score of less than 10 is recorded for the frame. In this case the score for the frame is the number of pins knocked down.

* A spare is where all ten pins are knocked down after the second throw. The total value of a spare is 10 plus the number of pins knocked down in their next throw.

* A strike is where all ten pins are knocked down after the first throw. The total value of a strike is 10 plus the number of pins knocked down in their next two throws. If a strike is immediately followed by a second strike, then we can not total the value of first strike until they throw the ball one more time.

Here is a three frame example:

| Frame 1         | Frame 2       | Frame 3                |
| :-------------: |:-------------:| :---------------------:|
| X (strike)      | 5/ (spare)    | 9 0 (open frame)       |

Frame 1 is (10 + 5 + 5) = 20

Frame 2 is (5 + 5 + 9) = 19

Frame 3 is (9 + 0) = 9

This means the current running total is 48.

The tenth frame in the game is a special case. If someone throws a strike or a spare then they get a fill ball. Fill balls exist to calculate the total of the 10th frame. Scoring a strike or spare on the fill ball does not give the player more fill balls. The total value of the 10th frame is the total number of pins knocked down.

For a tenth frame of X1/ (strike and a spare), the total value is 20.

For a tenth frame of XXX (three strikes), the total value is 30.

## Requirements

Write code to keep track of the score of a game of bowling.

*The game can be started using `Bowling.start`. This initiates
an Agent, and start returns the agent's PID. `game = Bowling.start`.*

It should support two operations:

* `roll(pid, pins : int)` is called each time the player rolls a ball. The argument is the number of pins knocked down.
* `score(pid) : int` is called only at the very end of the game. It returns the total score for that game.


## Todo

- [x] **Stage 1**: Implement the Kata. It should pass the test suite provided on Exercism.
- [ ] **Stage 2**: Modify to generate a running score chart; the data structure it produces should mirror a bowling card.
- [ ] **Stage 3**: This implements a single game for a single player. Implementation should now supervised isolated application.
- [ ] **Stage 4**: Implement a game server that allows multiple players (stub players).
- [ ] **Stage 5**: Allow multiple games (should follow naturally from stage 4).
- [ ] **Stage 6**: Implement players as processes.
- [ ] **Stage 7**: Implement a lobby where players can start and join games.
- [ ] **Stage 8**: Implement serialization of relevant state, allowing it to be used over sockets.
- [ ] **Stage 9**: Web frontend - use previous in a Phoenix app, and send receive via channels.
- [ ] **Stage 10**: Game UI - build rudimentary game UI. Could be JS, could be ASM, etc.
- [ ] **Stage 11**: Investigate & implement auth.
- [ ] **Stage 12**: Investigate saving state - what should be saved, when.
