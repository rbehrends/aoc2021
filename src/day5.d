import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.regex;
import std.typecons;
import std.math;

struct Point {
  int x, y;
}

struct Vector {
  Point start, end;
}

long countOverlaps(Vector[] vectors, bool includeDiagonals) {
  long[Point] matrix;
  foreach (vector; vectors) {
    auto start = vector.start;
    auto end = vector.end;
    if (!includeDiagonals && start.x != end.x && start.y != end.y)
      continue;
    matrix[start]++;
    while (start != end) {
      start.x += sgn(end.x - start.x);
      start.y += sgn(end.y - start.y);
      matrix[start]++;
    }
  }
  long total = 0;
  foreach (count; matrix.byValue) {
    if (count > 1)
      total++;
  }
  return total;
}

void main(string[] args) {
  const filename = args[1];
  const lines = filename.readText.splitLines;
  Vector[] vectors = lines.map!((string line) {
    auto values = line.split(regex(r"[^0-9]+")).map!(to!int).array;
    Point start = {x: values[0], y: values[1]};
    Point end = {x: values[2], y: values[3]};
    return Vector(start, end);
  }).array;

  writefln("part 1: %d", countOverlaps(vectors, false));
  writefln("part 2: %d", countOverlaps(vectors, true));
}
