import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.regex;
import std.math;

void main(string[] args) {
  auto values = args[1].readText.matchAll(regex(r"-?[0-9]+"))
    .map!((match) => match.hit.to!int).array;
  auto xmin = values[0], xmax = values[1], ymin = values[2], ymax = values[3];
  assert(xmin > 0 && ymax < 0);
  bool hitTarget(int x, int y) {
    return x >= xmin && x <= xmax && y >= ymin && y <= ymax;
  }

  int ytop = 0;
  int numhits = 0;
  // Note that D ranges denote left-closed, right-open intervals, i.e.
  // a..b contains all integers x with a <= x < b.
  //
  // We estimate the lower bound for vx because we know that vx*(vx+1)/2
  // must be greater than or equal to xmin.
  //
  // While this seemingly eliminates only a small number of values for
  // vx, it culls the overll search space considerably, as it allows
  // us to avoid long fruitless searches with a small vx and a large
  // positive vy, approximately cutting the overall runtime in half.
  //
  // Note: IEEE754 requires square roots to be calculated with infinite
  // precision and rounded to the nearest floating point number. Thus,
  // we don't have to worry about the use of `ceil` resulting in an
  // off-by-one error when the result is an exact integer (as .5 and .25
  // can be represented exactly as floating point numbers).
  foreach (vx; (-0.5 + sqrt(0.25 + xmin * 2.0)).ceil.to!int .. xmax + 1) {
    // The lower bound for vy is obvious. The upper bound is a bit more
    // complex. if vy > 0, then the probe will hit y = 0 on its downward
    // trajectory again with dy = -vy-1 (where dy is the current y
    // velocity and vy is the original y velocity), at which point
    // any dy <= ymin will again miss the target area, therefore vy =
    // -ymin-1 is an upper bound.
    foreach (vy; ymin .. -ymin) {
      int x = 0, y = 0, yt = 0;
      int dx = vx, dy = vy;
      while (x <= xmax && y >= ymin) {
        x += dx;
        y += dy;
        dx -= dx.sgn;
        dy -= 1;
        yt = max(yt, y);
        if (hitTarget(x, y)) {
          ytop = max(ytop, yt);
          numhits++;
          break;
        }
      }
    }
  }
  writefln("part 1: %d", ytop);
  writefln("part 2: %d", numhits);
}
