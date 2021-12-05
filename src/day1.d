import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;

void main(string[] args) {
  const filename = args[1];
  const depths = filename.readText.splitLines.map!(to!int).array;
  long count = 0;
  for (size_t i = 1; i < depths.length; i++) {
    if (depths[i] > depths[i - 1]) {
      count++;
    }
  }
  writefln("part 1: %d", count);
  count = 0;
  for (size_t i = 3; i < depths.length; i++) {
    // When comparing the sums of successive triples,
    // the two common entries cancel each other out.
    if (depths[i] > depths[i - 3]) {
      count++;
    }
  }
  writefln("part 2: %d", count);
}
