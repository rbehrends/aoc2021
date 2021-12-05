import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;

// This is a "too clever by half" solution, yes.

void main(string[] args) {
  const filename = args[1];
  const lines = filename.readText.splitLines;
  const values = lines.map!((x) => to!int(x, 2)).array;
  const width = lines.front.length;
  int gamma = 0;
  for (int mask = 1 << (width - 1); mask != 0; mask >>= 1) {
    long sum = 0;
    foreach (value; values) sum += value & mask;
    if (sum * 2 > values.length * mask) gamma |= mask;
  }
  const epsilon = ((1 << width) - 1) ^ gamma;
  writefln("part 1: %d", gamma * epsilon);
  
  auto oxyData = values.dup;
  auto co2Data = values.dup;
  for (int mask = 1 << (width - 1); mask != 0; mask >>= 1) {
    int oxySum = 0;
    int co2Sum = 0;
    foreach (value; oxyData) oxySum += value & mask;
    foreach (value; co2Data) co2Sum += value & mask;
    if (oxyData.length > 1) {
      const int oxyMask = oxySum * 2 >= oxyData.length * mask ? mask : 0;
      oxyData = oxyData.filter!((x) => (x & mask) == oxyMask).array;
    }
    if (co2Data.length > 1) {
      const int co2Mask = co2Sum * 2 < co2Data.length * mask ? mask : 0;
      co2Data = co2Data.filter!((x) => (x & mask) == co2Mask).array;
    }
  }
  writefln("part 2: %d", oxyData.front * co2Data.front);
}
