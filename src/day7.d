import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.math;
import std.range;

// This problem can be brute-forced (see alternative solution in
// day7a.d). This is a future-proof solution intended to deal with
// possible advances in crab civil engineering and issues of scale
// arising therefrom.

long cost(const long[] positions, long targetPos) {
  return positions.map!((p) => abs(p - targetPos)).sum;
}

long cost2(const long[] positions, long targetPos) {
  return positions.map!((p) {
    auto dist = abs(p - targetPos);
    return dist * (dist + 1) / 2;
  }).sum;
}

long deltaCost2(const long[] positions, long fromPos) {
  // == cost2(positions, fromPos + 1) - cost2(positions, fromPos)
  return positions.map!((p) => fromPos - p + (fromPos >= p)).sum;
}

void main(string[] args) {
  long[] positions = args[1].readText.strip.split(",").map!(to!long).array;
  // The first position is the median (in the case of an even number of
  // inputs, either of the two candidates can be chosen). Reason: moving
  // off the median increases the fuel cost for more or an equal number
  // of crabs compared to those who have a reduced fuel cost.
  positions.sort;
  auto minFuel = cost(positions, positions[$ / 2]);
  writefln("part 1: %d", minFuel);
  // For part 2, we observe that we are looking for the minimum of a
  // quadratic function, albeit over a discrete domain, so we are
  // going to look for the (approximate) root of the derivative, i.e.
  // where the slope stops decreasing.
  // Why is cost2 quadratic? Because:
  //   cost2(pos, x) = sum(p in pos, (x-p)*(x-p+1)/2)
  const minPos = positions[0];
  const maxPos = positions[$ - 1];
  auto sorted = assumeSorted(iota(minPos, maxPos+1).map!((p) => deltaCost2(positions, p)));
  // Evaluates the range lazily, so O(log sorted.length) accesses,
  // each evaluation requiring O(positions.length) arithmetic operations.
  // Returns a range of all values less than 0. Its length is the position
  // we need as the result.
  auto decreasing = sorted.lowerBound(0);
  writefln("part 2: %d", cost2(positions, decreasing.length));
}

