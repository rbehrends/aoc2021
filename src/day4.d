import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.regex;

class Board {
  // marked positions are encoded as a 5*5 bit matrix stored in an unsigned
  // 32-bit integer. This allows us to do marking in constant time with a
  // very small constant.
  uint marked = 0;
  int lastMarked = -1;
  int[] numbers;
  long[] numberPos;

  shared static uint[5 * 5] rowMasks;
  shared static uint[5 * 5] colMasks;

  static this() {
    enum rowMask1 = 0b11111;
    enum colMask1 = 0b00001_00001_00001_00001_00001;
    foreach (row; 0 .. 5) {
      foreach (col; 0 .. 5) {
        const index = row * 5 + col;
        rowMasks[index] = rowMask1 << (row * 5);
        colMasks[index] = colMask1 << col;
      }
    }
  }

public:
  bool complete = false;

  this(int[] numbers) {
    this.numbers = numbers;
    numberPos = replicate([-1L], 100);
    foreach (pos, num; numbers) {
      numberPos[num] = pos;
    }
  }

  void mark(int num) {
    lastMarked = num;
    const pos = numberPos[num];
    if (pos >= 0) {
      marked |= (1 << pos);
      // check if this completed either a row or a column.
      if ((marked & rowMasks[pos]) == rowMasks[pos] || (marked & colMasks[pos]) == colMasks[pos])
        complete = true;
      return;
    }
  }

  void print() {
    foreach (row; 0 .. 5) {
      foreach (col; 0 .. 5) {
        bool highlight = (marked & (1 << (row * 5 + col))) != 0;
        if (highlight)
          write("\x1b[32m");
        writef("%3d", numbers[row * 5 + col]);
        if (highlight)
          write("\x1b[0m");
      }
      writeln();
    }
  }

  int checksum() {
    int result = 0;
    foreach (i; 0 .. 5 * 5) {
      if ((marked & (1 << i)) == 0)
        result += numbers[i];
    }
    return result * lastMarked;
  }
}

void main(string[] args) {
  const filename = args[1];
  const string[] records = filename.readText.split("\n\n");
  const int[] drawnNumbers = records.front.split(",").map!(to!int).array;
  Board[] boards = records[1 .. $].map!((boardDesc) {
    int[] numbers = boardDesc.strip.split(regex(r"[ \n]+")).map!(to!int).array;
    return new Board(numbers);
  }).array;
  Board[] results = [];
  foreach (num; drawnNumbers) {
    foreach (board; boards) {
      if (!board.complete) {
        board.mark(num);
        if (board.complete)
          results ~= board;
      }
    }
  }
  writefln("part 1: %d", results.front.checksum);
  results.front.print;
  writefln("part 2: %d", results.back.checksum);
  results.back.print;
}
