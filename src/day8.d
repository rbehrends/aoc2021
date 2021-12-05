import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.math;
import core.bitop;

struct InOutData {
  byte[] inputs, outputs;
}

private int[8] calculateUniqueEncodings() {
  int[8] result = replicate([-1], 8);
  result[2] = 1;
  result[3] = 7;
  result[4] = 4;
  result[7] = 8;
  return result;
}

static uniqueEncodings = calculateUniqueEncodings();

void countUniqueOutputs(InOutData[] data) {
  int total = 0;
  foreach (item; data)
    foreach (output; item.outputs)
      if (uniqueEncodings[output.popcnt] >= 0)
        total++;
  writefln("part 1: %d", total);
}

void decodeData(InOutData[] data) {
  int total = 0;
  foreach (item; data) {
    int[128] decoding;
    int[10] encoding;
    void encode(byte input, int digit) {
      decoding[input] = digit;
      encoding[digit] = input;
    }
    // By sorting the inputs by bitcount, we can ensure that
    // the ambiguous cases (bitcount 5 and 6) are only processed
    // if encodings are already established for digits 1 and 4,
    // which are the only ones we rely on. Thus, we can process
    // all values in a single pass.
    item.inputs.sort!((a, b) => a.popcnt < b.popcnt);
    foreach (input; item.inputs) {
      if (uniqueEncodings[input.popcnt] >= 0)
        encode(input, uniqueEncodings[input.popcnt]);
      else if (input.popcnt == 5) { // must be 2, 3, or 5
        if ((input & encoding[1]) == encoding[1])
          encode(input, 3);
        else if ((input & encoding[4]).popcnt == 2)
          encode(input, 2);
        else
          encode(input, 5);
      } else { // must be 0, 6 or 9.
        if ((input & encoding[4]) == encoding[4])
          encode(input, 9);
        else if ((input & encoding[1]) == encoding[1])
          encode(input, 0);
        else
          encode(input, 6);
      }
    }
    total += item.outputs.fold!((acc, output) => acc * 10 + decoding[output])(0);
  }
  writefln("part 2: %d", total);
}

byte computeBits(string pattern) {
  return to!byte(pattern.map!((ch) => (1 << (ch - 'a'))).sum);
}

void main(string[] args) {
  InOutData[] data = args[1].readText.strip.splitLines.map!((line) {
    InOutData result;
    string[] pair = line.split(" | ");
    result.inputs = pair[0].split(" ").map!computeBits.array;
    result.outputs = pair[1].split(" ").map!computeBits.array;
    return result;
  }).array;
  countUniqueOutputs(data);
  decodeData(data);
}
