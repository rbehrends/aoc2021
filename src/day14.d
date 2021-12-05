import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.range;

void genSimple(string sequence, char[string] rules, int iterations) {
  foreach (i; 0..iterations) {
    string output = sequence[0..1];
    foreach (pair; sequence.slide(2).map!(to!string)) {
      if (pair in rules)
        output ~= rules[pair];
      output ~= pair[1];
    }
    sequence = output;
  }
  int[char] elemCount;
  foreach (char ch; sequence) {
    elemCount[ch]++;
  }
  auto sorted = elemCount.values.sort;
  writefln("part 1: %d", sorted[$-1] - sorted[0]);
}

void genSmart(string sequence, char[string] rules, int iterations) {
  long[string] pairCount;
  long[char] elemCount;
  foreach (char ch; sequence)
    elemCount[ch]++;
  foreach (pair; sequence.slide(2).map!(to!string))
    pairCount[pair]++;
  foreach (i; 0..iterations) {
    auto newPairCount = pairCount.dup;
    foreach (pair, count; pairCount) {
      if (pair in rules) {
        char ch = rules[pair];
        elemCount[ch] += count;
        newPairCount[[pair[0], ch]] += count;
        newPairCount[[ch, pair[1]]] += count;
        newPairCount[pair] -= count;
      }
    }
    pairCount = newPairCount;
  }
  auto sorted = elemCount.values.sort;
  writefln("part 2: %d", sorted[$-1] - sorted[0]);
}

void main(string[] args) {
  const records = args[1].readText.strip.split("\n\n");
  string initial = records[0];
  char[string] rules;
  foreach (rule; records[1].splitLines) {
    rules[rule[0..2]] = rule[6];
    assert(rule[2..6] == " -> ");
  }
  genSimple(initial, rules, 10);
  genSmart(initial, rules, 40);
}
