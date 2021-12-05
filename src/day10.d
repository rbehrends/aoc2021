import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;

const openBrackets = "([{<";
const closingBrackets = ")]}>";
const errorScores = [3, 57, 1197, 25137];

void main(string[] args) {
  const lines = args[1].readText.strip.splitLines;
  long errorScore = 0;
  long[] completionScores;
  outer: foreach (line; lines) {
    long[] stack;
    foreach (char ch; line) {
      auto p = openBrackets.indexOf(ch);
      if (p >= 0) {
        stack ~= p;
      } else {
        p = closingBrackets.indexOf(ch);
        assert(p >= 0);
        if (stack.length > 0 && stack.back == p) {
          stack.length--;
        } else {
          // error
          errorScore += errorScores[p];
          continue outer;
        }
      }
    }
    completionScores ~= stack.reverse.fold!((acc, p) => acc * 5 + p + 1)(0L);
  }
  writefln("part 1: %d", errorScore);
  completionScores.sort;
  writefln("part 2: %d", completionScores[$ / 2]);
}
