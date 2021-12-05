import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;

const cycleLength = 6;
const newCycleLength = 8;

long countSimple(const int[] timers, int days) {
  auto currentTimers = timers.dup;
  foreach (day; 0 .. days) {
    const len = currentTimers.length;
    foreach (i; 0 .. len) {
      if (--currentTimers[i] < 0) {
        currentTimers[i] = cycleLength;
        currentTimers ~= newCycleLength;
      }
    }
  }
  return currentTimers.length;
}

long countSmart(const int[] timers, int days) {
  long[newCycleLength + 1] count;
  foreach (age; timers)
    count[age]++;
  foreach (day; 0 .. days) {
    const newFish = count[0];
    count[0 .. $ - 1] = count[1 .. $];
    count[cycleLength] += newFish;
    count[newCycleLength] = newFish;
  }
  return sum(count[]);
}

unittest {
  const testdata = [3, 4, 3, 1, 2];
  const maxDays = 80;
  assert(countSimple(testdata, 18) == 26);
  foreach (days; 0 .. maxDays)
    assert(countSimple(testdata, days) == countSmart(testdata, days));
}

void main(string[] args) {
  int[] timers = args[1].readText.strip.split(",").map!(to!int).array;
  writefln("part 1: %d", countSimple(timers, 80));
  writefln("part 2: %d", countSmart(timers, 256));
}
