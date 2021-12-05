import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.math;
import std.range;

long cost(const long[] positions, long targetPos) {
  return positions.map!((p) => abs(p - targetPos)).sum;
}

long cost2(const long[] positions, long targetPos) {
  return positions.map!((pos) {
    const dist = abs(pos - targetPos);
    return dist * (dist + 1) / 2;
  }).sum;
}

void main(string[] args) {
  long[] positions = args[1].readText.strip.split(",").map!(to!long).array;
  const maxPos = positions.reduce!max;
  const minPos = positions.reduce!min;
  const minFuel = iota(minPos, maxPos + 1).map!((p) => cost(positions, p))
    .reduce!min;
  writefln("part 1: %d", minFuel);
  const minFuel2 = iota(minPos, maxPos + 1).map!((p) => cost2(positions, p))
    .reduce!min;
  writefln("part 2: %d", minFuel2);
}
