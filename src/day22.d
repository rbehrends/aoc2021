import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.regex;
import std.range;

struct Pos {
  int x, y, z;
}

struct Op {
  bool on;
  Pos start, end;
}

void reactorInitialization(const Op[] ops) {
  bool[Pos] cubes;
  const lo = -50, hi = 50;
  foreach (ref op; ops) {
    foreach (x; max(op.start.x, lo) .. min(op.end.x, hi) + 1) {
      foreach (y; max(op.start.y, lo) .. min(op.end.y, hi) + 1) {
        foreach (z; max(op.start.z, lo) .. min(op.end.z, hi) + 1) {
          auto pos = Pos(x, y, z);
          cubes[pos] = op.on;
        }
      }
    }
  }
  auto total = cubes.values.count!((x) => x);
  writefln("part 1: %d", total);
}

// We rely on the following basic rules from set theory:
//
//   | A + B | = | A | - | A * B | + | B |
//   | A \ B |  = | A | - | A * B |
//
// where '+' indicates set union, '*' set intersection, and
// '\' indicates set difference to transform operations on
// possibly overlapping sets into operations with simple
// arithmetic.
//
// If we model "on" operations as set union and "off" operations
// as set differences, we can subtract "off" operations from
// "on" operations, and vice versa, and similarly add operations
// of the same type together.

void addIntersection(ref long[Op] set, Op a, Op b, long count, bool on) {
  Op result = {on: on};
  int x0 = max(a.start.x, b.start.x);
  int x1 = min(a.end.x, b.end.x);
  int y0 = max(a.start.y, b.start.y);
  int y1 = min(a.end.y, b.end.y);
  int z0 = max(a.start.z, b.start.z);
  int z1 = min(a.end.z, b.end.z);
  if (x1 >= x0 && y1 >= y0 && z1 >= z0) {
    result.start = Pos(x0, y0, z0);
    result.end = Pos(x1, y1, z1);
    set[result] += count;
  }
}

void reactorReboot(const Op[] ops) {
  long[Op] set;
  foreach (newOp; ops) {
    long[Op] newSet;
    foreach (existingOp, count; set) {
      newSet[existingOp] += count;
      // The condition !existingOp.on is a simplification of four cases:
      //
      // union followed by union => exclude intersection
      //   to cancel out double inclusion.
      // union followed by difference => exclude intersection
      //   to give effect to the difference operation.
      // difference followed by difference => include intersection
      //  to cancel out double exclusion.
      // difference followed by union => include intersection
      //  to add the subset back in.
      addIntersection(newSet, newOp, existingOp, count, !existingOp.on);
    }
    // New set differences have already been accounted for by adding or
    // subtracting the intersection above, we only need to add set unions.
    if (newOp.on)
      newSet[newOp] += 1;
    set = newSet;
  }
  long total = 0;
  foreach (op, count; set) {
    long size = 1L;
    size *= op.end.x - op.start.x + 1;
    size *= op.end.y - op.start.y + 1;
    size *= op.end.z - op.start.z + 1;
    size *= count;
    total += op.on ? size : -size;
  }
  writefln("part 2: %d", total);
}

void main(string[] args) {
  string[] lines = args[1].readText.splitLines;
  Op[] ops = lines.map!((line) {
    int[] numbers = line.matchAll(regex(r"-?[0-9]+")).map!((match) => match.hit.to!int).array;
    bool on = line.startsWith("on");
    Pos start = {x: numbers[0], y: numbers[2], z: numbers[4]};
    Pos end = {x: numbers[1], y: numbers[3], z: numbers[5]};
    Op op = {on: on, start: start, end: end};
    return op;
  }).array;
  reactorInitialization(ops);
  reactorReboot(ops);
}
