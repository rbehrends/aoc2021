import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.range;

struct Pos {
  long row, col;
}

Pos[] adjacent(T)(T[][] grid, long row, long col) {
  Pos[] result;
  foreach (dy; -1 .. 2)
    foreach (dx; -1 .. 2) {
      if (dx == 0 && dy == 0)
        continue;
      auto r = row + dy;
      auto c = col + dx;
      if (r >= 0 && r < grid.length && c >= 0 && c < grid[r].length)
        result ~= Pos(r, c);
    }
  return result;
}

void main(string[] args) {
  const lines = args[1].readText.splitLines;
  int[][] grid = lines.map!((line) => line.map!((ch) => to!int(ch - '0')).array).array;
  const rows = grid.length;
  const columns = grid.front.length;

  int totalFlashes = 0;

  int updateGrid() {
    int flashes = 0;
    void levelup(long row, long col) {
      if (++grid[row][col] == 10) {
        flashes++;
        foreach (pos; grid.adjacent(row, col))
          levelup(pos.row, pos.col);
      }
    }

    foreach (row; 0 .. rows)
      foreach (col; 0 .. columns)
        levelup(row, col);
    foreach (row; 0 .. rows)
      foreach (col; 0 .. columns)
        if (grid[row][col] > 9)
          grid[row][col] = 0;
    return flashes;
  }

  for (int step = 1; step <= 100; step++)
    totalFlashes += updateGrid();
  writefln("part 1: %d", totalFlashes);
  for (int step = 101;; step++) {
    if (updateGrid() == 100) {
      writefln("part 2: %d", step);
      break;
    }
  }
}
