import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.range;
import std.container;
import std.math;

const numCritterTypes = 4;
const width = numCritterTypes * 2 + 3;

const static safeHallwaySpots = iota(width).filter!((x) => !(x % 2 == 0
    && x / 2 >= 1 && x / 2 <= numCritterTypes)).array;

static int[numCritterTypes + 1] energyTable = [0, 1, 10, 100, 1000];

class State(int height) {
private:
  alias Layout = byte[width][height];
  Layout spaces;
  int energy;
  State prev;

  void generateMoves(T)(T container) {
    // We only need to consider two types of moves.
    // 1. Out of a side room that contains any wrong
    //    amphipods.
    // 2. Out of a hallway into the target side room
    //    for that amphipod.
    // Any other moves are either part of the above
    // moves or composed of the above moves.
    foreach (row; 0 .. height) {
      foreach (col; 0 .. width) {
        auto critterType = spaces[row][col];

	State moveTo(int targetRow, int targetCol) {
	  auto result = clone();
	  result.spaces[row][col] = 0;
	  result.spaces[targetRow][targetCol] = critterType;
	  auto distance = abs(targetCol - col) + abs(targetRow - row);
	  result.energy += distance * energyTable[critterType];
	  return result;
	}

        if (critterType != 0) {
          if (row == 0) {
            // move out of hallway into side room
            auto targetCol = critterType * 2;
	    // invalid if wrong type amphipod still in that side room.
            if (!validCol(targetCol))
              continue;
            auto dir = sgn(targetCol - col);
	    // are all intermediate hallway spots clear?
	    if (iota(col + dir, targetCol, dir).any!((c) => spaces[row][c]))
	      continue;
	    // go as far into the side room as we can.
            auto targetRow = 1;
            while (targetRow + 1 < height
	           && spaces[targetRow + 1][targetCol] == 0) {
              targetRow++;
            }
            container.insert(moveTo(targetRow, targetCol));
          } else {
            // move out of side room into hallway
	    // no point in moving out of our destination.
            if (validCol(col))
              continue;
	    // are all spots on the way to the hallway clear?
	    if (iota(1, row).any!((r) => spaces[r][col]))
	      continue;
	    // try all possible hallway locations.
	    foreach (targetCol; safeHallwaySpots) {
              auto dir = sgn(targetCol - col);
	      // are all intermediate hallway spots clear?
	      if (iota(col, targetCol + dir, dir).any!((c) => spaces[0][c]))
	        continue;
	      container.insert(moveTo(0, targetCol));
            }
          }
        }
      }
    }
  }

  bool finalState() {
    foreach (i; 1 .. 5) {
      if (spaces[1][i * 2] != i || spaces[2][i * 2] != i)
        return false;
    }
    return true;
  }

public:
  this(State state) {
    this.spaces = state.spaces;
    this.energy = state.energy;
    this.prev = state;
  }

  this() {
  }

  State clone() {
    return new State(this);
  }

  bool validCol(int col) {
    // By way of constructions, we know that there won't be any
    // holes. Any room will be filled from the bottom up.
    int critterType = col / 2;
    foreach (row; 1 .. height) {
      if (spaces[row][col] != 0 && spaces[row][col] != critterType)
        return false;
    }
    return true;
  }

  int search() {
    auto pqueue = BinaryHeap!(State[], (a, b) => a.energy > b.energy)([this]);
    bool[Layout] seen;
    while (!pqueue.empty) {
      auto state = pqueue.front;
      pqueue.popFront();
      if (state.finalState())
        return state.energy;
      if (state.spaces in seen)
        continue;
      seen[state.spaces] = true;
      state.generateMoves(pqueue);
    }
    assert(false);
  }

  override string toString() {
    string output;
    if (prev) {
      output = prev.toString;
      output ~= "\n -->\n";
    }
    foreach (row; 0 .. height) {
      foreach (col; 0 .. width) {
        output ~= ".ABCD"[spaces[row][col]];
      }
      output ~= "\n";
    }
    output ~= energy.to!string;
    return output;
  }
}

void main(string[] args) {
  auto lines = args[1].readText.splitLines;
  auto start = new State!(3)();
  foreach (i; 1 .. 5) {
    start.spaces[1][2 * i] = (lines[2][2 * i + 1] - 'A' + 1).to!byte;
    start.spaces[2][2 * i] = (lines[3][2 * i + 1] - 'A' + 1).to!byte;
  }
  writefln("part 1: %d", start.search());
  auto start2 = new State!(5)();
  start2.spaces[1] = start.spaces[1];
  start2.spaces[2] = [0, 0, 4, 0, 3, 0, 2, 0, 1, 0, 0];
  start2.spaces[3] = [0, 0, 4, 0, 2, 0, 1, 0, 3, 0, 0];
  start2.spaces[4] = start.spaces[2];
  start2.search();
  writefln("part 2: %d", start2.search());
}
