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
  if (row > 0)
    result ~= Pos(row - 1, col);
  if (row + 1 < grid.length)
    result ~= Pos(row + 1, col);
  if (col > 0)
    result ~= Pos(row, col - 1);
  if (col + 1 < grid[row].length)
    result ~= Pos(row, col + 1);
  return result;
}

void main(string[] args) {
  const lines = args[1].readText.splitLines;
  int[][] grid = lines.map!((line) => line.map!((ch) => to!int(ch - '0')).array).array;
  const rows = grid.length;
  const columns = grid.front.length;

  int risk = 0;
  Pos[] lowPoints = [];
  foreach (row; 0 .. rows) {
    foreach (col; 0 .. columns) {
      const value = grid[row][col];
      if (grid.adjacent(row, col).all!((adj) => grid[adj.row][adj.col] > value)) {
        risk += value + 1;
        lowPoints ~= Pos(row, col);
      }
    }
  }
  writefln("part 1: %d", risk);

  auto seen = new bool[][](rows, columns);
  int search(int lastValue, long row, long col) {
    // standard dfs algorithm
    if (seen[row][col])
      return 0;
    const newValue = grid[row][col];
    if (newValue <= lastValue || newValue == 9)
      return 0;
    seen[row][col] = true;
    int size = 1;
    foreach (adj; grid.adjacent(row, col))
      size += search(newValue, adj.row, adj.col);
    return size;
  }

  int[] basinSizes;
  foreach (pos; lowPoints)
    basinSizes ~= search(-1, pos.row, pos.col);
  basinSizes.sort!q{a > b};
  writefln("part 2: %d", basinSizes.take(3).fold!q{a * b}(1));
}
