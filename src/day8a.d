import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.math;
import core.bitop;

struct InOutData {
  string[] inputs, outputs;
}

void countUniqueOutputs(InOutData[] data) {
  const static uniques = [2, 3, 4, 7];
  int total = 0;
  foreach (item; data)
    foreach (output; item.outputs)
      if (canFind(uniques, output.length))
        total++;
  writefln("part 1: %d", total);
}

static defaults = [
  "abcefg", "cf", "acdeg", "acdfg", "bcdf", // 0..4
  "abdfg", "abdefg", "acf", "abcdefg",
  "abcdfg" // 5..9
];

// We exploit the fact that the multiset { freq[ch] | ch in code }
// is unique for each digit and encoding-independent.

int[] charFrequencies(string[] codes) {
  int[7] freq;
  foreach (char ch; "abcdefg")
    foreach (code; codes)
      if (canFind(code, ch))
        freq[ch - 'a']++;
  return freq.dup;
}

alias FreqProfile = byte[10];

FreqProfile freqProfile(string code, int[] freq) {
  FreqProfile result;
  foreach (char ch; code)
    result[freq[ch-'a']]++;
  return result;
}

int[FreqProfile] calculateCodeTable() {
  int[FreqProfile] codeTable;
  auto freq = charFrequencies(defaults);
  foreach (digit, code; defaults)
    codeTable[freqProfile(code, freq)] = to!int(digit);
  assert(codeTable.length == 10);
  return codeTable;
}

int[FreqProfile] codeTable;

static this() {
  codeTable = calculateCodeTable();
}

void decodeData(InOutData[] data) {
  int total = 0;
  foreach (item; data) {
    auto freq = charFrequencies(item.inputs);
    int num = 0;
    foreach (output; item.outputs)
      num = num * 10 + codeTable[freqProfile(output, freq)];
    total += num;
  }
  writefln("part 2: %d", total);
}

void main(string[] args) {
  InOutData[] data = args[1].readText.strip.splitLines.map!((line) {
    InOutData result;
    string[] pair = line.split(" | ");
    result.inputs = pair[0].split(" ").array;
    result.outputs = pair[1].split(" ").array;
    return result;
  }).array;
  countUniqueOutputs(data);
  decodeData(data);
}
