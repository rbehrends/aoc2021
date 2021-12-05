import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.container;

struct Pos {
  int x, y;
}

struct Path {
  int risk;
  Pos pos;
}

int findLowestRiskPath(const byte[][] grid) {
  auto xsize = grid.length;
  auto ysize = grid.front.length;
  auto visited = new bool[][](xsize, ysize);
  Path current = Path(0, Pos(0, 0));
  auto pqueue = BinaryHeap!(Path[], q{a.risk > b.risk})([current]);
  for (;;) {
    current = pqueue.front;
    pqueue.popFront();
    auto currX = current.pos.x, currY = current.pos.y;
    if (visited[currX][currY])
      continue;
    if (currX == xsize - 1 && currY == ysize - 1)
      break;
    visited[currX][currY] = true;
    foreach (delta; [Pos(1, 0), Pos(0, 1), Pos(-1, 0), Pos(0, -1)]) {
      auto nextX = currX + delta.x, nextY = currY + delta.y;
      if (nextX >= 0 && nextY >= 0 && nextX < xsize && nextY < ysize && !visited[nextX][nextY])
        pqueue.insert(Path(current.risk + grid[nextX][nextY], Pos(nextX, nextY)));
    }
  }
  return current.risk;
}

byte[][] replicateGrid(const byte[][] grid, int rep) {
  auto xsize = grid.length;
  auto ysize = grid.front.length;
  auto result = new byte[][](xsize * rep, ysize * rep);
  foreach (x; 0 .. result.length) {
    foreach (y; 0 .. result[x].length)
      result[x][y] = (grid[x % xsize][y % ysize] + x / xsize + y / ysize - 1) % 9 + 1;
  }
  return result;
}

void main(string[] args) {
  const lines = args[1].readText.splitLines;
  byte[][] grid = lines.map!((line) => line.map!((ch) => to!byte(ch - '0')).array).array;
  byte[][] grid2 = replicateGrid(grid, 5);
  writefln("part 1: %d", findLowestRiskPath(grid));
  writefln("part 2: %d", findLowestRiskPath(grid2));
}
