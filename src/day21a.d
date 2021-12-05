import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;

// Variant of day21.d, which uses a multidimensional array
// instead of an associative array to store the data. This
// is faster and uses less memory, but is also less readable,
// due to the five levels of indexing necessary.

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

void runWithDiracDice(const int[] startingPositions) {
  // Dynamic programming, keeping track of a matrix of
  // the set of possible game states for a given pair
  // of scores.
  const winningScore = 21;
  const maxScoreInc = 10;
  const maxPos = 10;
  // needs to be static or we may overflow the stack.
  static long[2][maxPos][maxPos][winningScore + maxScoreInc][winningScore + maxScoreInc] scores;
  scores[0][0][startingPositions[0] - 1][startingPositions[1] - 1][0] = 1;
  foreach (p0Score; 0 .. winningScore) {
    foreach (p1Score; 0 .. winningScore) {
      foreach (pos0; 0 .. maxPos) {
        foreach (pos1; 0 .. maxPos) {
          foreach (player; 0 .. 2) {
            long count = scores[p0Score][p1Score][pos0][pos1][player];
            if (count == 0)
              continue;
            foreach (roll1; 1 .. 4) {
              foreach (roll2; 1 .. 4) {
                foreach (roll3; 1 .. 4) {
                  auto pos = player == 0 ? pos0 : pos1;
                  pos += roll1 + roll2 + roll3;
                  pos %= maxPos;
                  const points = pos + 1;
                  if (player == 0) {
                    auto newP0Score = p0Score + points;
                    scores[newP0Score][p1Score][pos][pos1][1 - player] += count;
                  } else {
                    auto newP1Score = p1Score + points;
                    scores[p0Score][newP1Score][pos0][pos][1 - player] += count;
                  }
                }
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
      foreach (pos0; 0 .. maxPos) {
        foreach (pos1; 0 .. maxPos) {
          // Note: the player index is counter-intutively inverted,
          // as a winning state for player 0 has player 1 acting on
          // the next turn, abnd vice versa.
          p0Wins += scores[scoreWin][scoreLoss][pos0][pos1][1];
          p1Wins += scores[scoreLoss][scoreWin][pos0][pos1][0];
          assert(scores[scoreWin][scoreLoss][pos0][pos1][0] == 0);
          assert(scores[scoreLoss][scoreWin][pos0][pos1][1] == 0);
        }
      }
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
