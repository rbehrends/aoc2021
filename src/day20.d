import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;

struct Coord {
  long row, col;
}

struct Image {
  bool[][] data;
  bool inverted;
}

Image enhanceImage(Image input, bool[] enhancer) {
  long rows = input.data.length;
  long columns = input.data[0].length;
  Image output = {
    data: new bool[][](rows + 2, columns + 2),
    inverted: input.inverted ^ enhancer[0]
  };
  foreach (row; -1 .. rows + 1) {
    foreach (col; -1 .. columns + 1) {
      int pattern;
      foreach (adjRow; row - 1 .. row + 2) {
        foreach (adjCol; col - 1 .. col + 2) {
          pattern <<= 1;
          if (adjRow >= 0 && adjRow < rows && adjCol >= 0 && adjCol < columns
              && input.data[adjRow][adjCol])
            pattern |= 1;
        }
      }
      bool light = enhancer[pattern ^ (input.inverted ? 0b111_111_111 : 0)];
      output.data[row + 1][col + 1] = output.inverted ^ light;
    }
  }
  return output;
}

long countPixels(Image image) {
  return image.data.map!((row) => row.map!((pixel) => pixel ? 1 : 0).sum).sum;
}

void main(string[] args) {
  const data = args[1].readText.split("\n\n");
  bool[] enhancer = data[0].map!((ch) => ch == '#').array;
  string[] grid = data[1].splitLines;
  Image image = {
    data: new bool[][](grid.length, grid.front.length),
    inverted: false
  };
  foreach (row, line; grid) {
    foreach (col, ch; line) {
      image.data[row][col] = ch == '#';
    }
  }
  foreach (i; 0 .. 2)
    image = enhanceImage(image, enhancer);
  writefln("part 1: %d", image.countPixels);
  foreach (i; 2 .. 50)
    image = enhanceImage(image, enhancer);
  writefln("part 2: %d", image.countPixels);
}
