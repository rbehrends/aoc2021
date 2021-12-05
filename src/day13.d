import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.regex;

struct Dot {
  int x, y;
}

struct Fold {
  string along;
  int at;
}

template foldInner(string along) {
  enum foldInner = q{
    foreach (dot; paper.keys.array) {
      if (dot.along > fold.at) {
        paper.remove(dot);
        dot.along = 2*fold.at - dot.along;
        paper[dot] = true;
      }
    }
  }.replace("along", along);
}

void foldPaper(ref bool[Dot] paper, Fold fold) {
  if (fold.along == "x") {
    mixin(foldInner!("x"));
  } else {
    mixin(foldInner!("y"));
  }
}

void draw(bool[Dot] paper) {
  writeln("part 2:");
  const xmax = paper.keys.fold!((x, dot) => max(x, dot.x))(0);
  const ymax = paper.keys.fold!((y, dot) => max(y, dot.y))(0);
  foreach (y; 0 .. ymax + 1) {
    foreach (x; 0 .. xmax + 1)
      write(Dot(x, y) in paper ? "#" : ".");
    writeln();
  }
}

void main(string[] args) {
  const parts = args[1].readText.split("\n\n").array;
  const dots = parts[0].splitLines.map!((line) {
    auto xy = line.split(",").map!(to!int).array;
    return Dot(xy[0], xy[1]);
  }).array;
  const pattern = regex(r"([xy])=([0-9]+)");
  const folds = parts[1].matchAll(pattern).map!((match) => Fold(match[1], match[2].to!int)).array;
  bool[Dot] paper;
  foreach (dot; dots)
    paper[dot] = true;
  foldPaper(paper, folds.front);
  writefln("part 1: %d", paper.length);
  foreach (fold; folds[1 .. $]) {
    foldPaper(paper, fold);
  }
  draw(paper);
}
