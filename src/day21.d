import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;

void runWithDeterministicDice(const int[] startingPositions) {
  const winningScore = 1000;
  int[2] positions = startingPositions[0 .. 2];
  int[2] scores;
  int die = 0;
  outer: for (;;) {
    foreach (i; 0 .. scores.length) {
      foreach (_; 0 .. 3) {
        positions[i] += (++die - 1) % 100 + 1;
        positions[i] = (positions[i] - 1) % 10 + 1;
      }
      scores[i] += positions[i];
      if (scores[i] >= winningScore)
        break outer;
    }
  }
  writefln("part 1: %d", die * scores.reduce!min);
}

struct GameState {
  int[2] positions;
  int currentPlayer;
}

// a multiset of game states.
alias GameStates = long[GameState];

void runWithDiracDice(const int[] startingPositions) {
  // Dynamic programming, keeping track of a matrix of
  // the set of possible game states for a given pair
  // of scores.
  const winningScore = 21;
  const maxScoreInc = 10;
  GameStates[winningScore + maxScoreInc][winningScore + maxScoreInc] scores;
  scores[0][0] = [GameState(startingPositions[0 .. 2], 0): 1];
  foreach (p0Score; 0 .. winningScore) {
    foreach (p1Score; 0 .. winningScore) {
      foreach (gamestate, count; scores[p0Score][p1Score]) {
        int currentPlayer = gamestate.currentPlayer;
        foreach (roll1; 1 .. 4) {
          foreach (roll2; 1 .. 4) {
            foreach (roll3; 1 .. 4) {
              GameState newstate = gamestate;
              newstate.currentPlayer = 1 - currentPlayer;
              auto pos = newstate.positions[currentPlayer];
              pos += roll1 + roll2 + roll3;
              pos = (pos - 1) % 10 + 1;
              newstate.positions[currentPlayer] = pos;
              const points = newstate.positions[currentPlayer];
              if (currentPlayer == 0) {
                auto newP0Score = p0Score + points;
                scores[newP0Score][p1Score][newstate] += count;
              } else {
                auto newP1Score = p1Score + points;
                scores[p0Score][newP1Score][newstate] += count;
              }
            }
          }
        }
      }
    }
  }
  long p0Wins = 0, p1Wins = 0;
  foreach (scoreWin; winningScore .. winningScore + maxScoreInc) {
    foreach (scoreLoss; 0 .. winningScore) {
      p0Wins += scores[scoreWin][scoreLoss].values.sum;
      p1Wins += scores[scoreLoss][scoreWin].values.sum;
    }
  }
  writefln("part 2: %d", max(p0Wins, p1Wins));
}

void main(string[] args) {
  const lines = args[1].readText.splitLines;
  int[] positions = lines.map!((line) => line.split.back.to!int).array;
  runWithDeterministicDice(positions);
  runWithDiracDice(positions);
}
