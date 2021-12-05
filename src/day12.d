import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.ascii;

void main(string[] args) {
  const lines = args[1].readText.strip.splitLines;
  const connections = lines.map!q{a.split("-")}.array;
  string[][string] neighbors;
  int[string] visited;

  foreach (conn; connections) {
    if (conn[1] != "start")
      neighbors[conn[0]] ~= conn[1];
    if (conn[0] != "start")
      neighbors[conn[1]] ~= conn[0];
    visited[conn[0]] = 0;
    visited[conn[1]] = 0;
  }

  int allPaths(string from, string to, int[string] seen) {
    if (from == to)
      return 1;
    int result = 0;
    foreach (adj; neighbors[from]) {
      if (from[0].isLower) {
        if (!seen[from]) {
          seen[from]++;
          result += allPaths(adj, to, seen);
          seen[from]--;
        }
      } else
        result += allPaths(adj, to, seen);
    }
    return result;
  }

  writefln("part 1: %d", allPaths("start", "end", visited));

  int allPaths2(string from, string to, int[string] seen, bool revisited) {
    if (from == to)
      return 1;
    int result = 0;
    foreach (adj; neighbors[from]) {
      if (from[0].isLower) {
        switch (seen[from]++) {
          case 0:
            result += allPaths2(adj, to, seen, revisited);
            break;
          case 1:
            if (!revisited)
              result += allPaths2(adj, to, seen, true);
            break;
          default:
            break;
        }
        seen[from]--;
      } else
        result += allPaths2(adj, to, seen, revisited);
    }
    return result;
  }

  writefln("part 2: %d", allPaths2("start", "end", visited, false));
}
