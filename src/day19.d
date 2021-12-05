import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.range;
import std.math;

// Custom representation of specific affine transformations
struct Transform {
  int[3] perm;
  int[3] flip;
  int[3] offset;
  this(const int[] perm, const int[] flip) {
    this.perm = perm[0 .. 3];
    this.flip = flip[0 .. 3];
  }

  this(Transform trans) {
    this.perm = trans.perm;
    this.flip = trans.flip;
    this.offset = trans.offset;
  }
}

struct Coord {
  int[3] value;
  Coord apply(Transform trans) {
    Coord result;
    static foreach (i; 0 .. 3)
      result.value[trans.perm[i]] = value[i];
    static foreach (i; 0 .. 3)
      result.value[i] *= trans.flip[i];
    static foreach (i; 0 .. 3)
      result.value[i] += trans.offset[i];
    return result;
  }

  Coord applyReverse(Transform[] transforms) {
    Coord result = this;
    foreach_reverse (trans; transforms) {
      result = result.apply(trans);
    }
    return result;
  }

  Coord opBinary(string op)(Coord other) {
    Coord result;
    static if (op == "+") {
      static foreach (i; 0 .. 3)
        result.value[i] = value[i] + other.value[i];
    } else static if (op == "-") {
      static foreach (i; 0 .. 3)
        result.value[i] = value[i] - other.value[i];
    } else static if (op == "==") {
      static foreach (i; 0 .. 3)
        if (value[i] != other.value[i])
          return false;
      return true;
    } else {
      static assert(false, "Operator " ~ op ~ " not implemented");
    }
    return result;
  }
}

// this basically generates the rotation group of a cube.

static const perms = [
  [0, 1, 2], [0, 2, 1], [1, 0, 2], [1, 2, 0], [2, 0, 1], [2, 1, 0]
];
static const parities = [0, 1, 1, 0, 0, 1];
static const flips = [[1, 1, 1], [-1, -1, 1], [-1, 1, -1], [1, -1, -1]];
static Transform[] rotations;

static this() {
  foreach (i, perm; perms) {
    foreach (flip; flips) {
      if (parities[i] == 0) {
        rotations ~= Transform(perm, flip);
      } else {
        auto invFlips = flip.map!((x) => -x).array;
        rotations ~= Transform(perm, invFlips);
      }
    }
  }
}

class ScannerArea {
  Coord[] beacons;
  Transform[] transforms; // transformations needed to reach this from start
  this(Coord[] beacons) {
    this.beacons = beacons;
  }

  Transform* tryMatch(ScannerArea other) {
    bool[Coord] originalBeacons;
    foreach (beacon; beacons) {
      originalBeacons[beacon] = true;
    }
    // try to match each possible pair of beacons,
    // then see how many of the rest match.
    foreach (beacon; beacons) {
      foreach (Transform trans; rotations) {
        // We won't find enough matches for the last 11 beacons if
        // we haven't already.
        foreach (i, beacon2; other.beacons[0 .. $ - 12]) {
          auto beacon2adjusted = beacon2.apply(trans);
          auto delta = beacon - beacon2adjusted;
          auto trans2 = trans;
          trans2.offset = delta.value;
          int matches = 1;
          // We don't test the first i+1 beacons again. The first `i` because
          // they can't be part of a set of 12+ or we'd have hit that already,
          // and we know that the i+1'th is a hit, because that's how we
          // constructed trans2. To account for that hit, we start with
          // matches = 1. Therefore, we use drop(i+1). Note that because i is
          // zero-based, the i+1'th item has index i.
          foreach (j, reorientedBeacon; other.beacons.drop(i + 1).map!((b) => b.apply(trans2))
              .array) {
            if (reorientedBeacon in originalBeacons)
              matches++;
            // if there are not enough possible matches left, abort early.
            if (matches + other.beacons.length - j < 12)
              break;
          }
          if (matches >= 12) {
            return new Transform(trans2);
          }
        }
      }
    }
    return null;
  }
}

void syncAreas(ScannerArea[] scannerAreas) {
  ScannerArea startingArea = scannerAreas.front;
  bool[ScannerArea] processedAreas = [startingArea: true];
  while (processedAreas.length != scannerAreas.length) {
    auto oldProcessedLength = processedAreas.length;
    foreach (area; processedAreas.byKey) {
      foreach (area2; scannerAreas) {
        if (area2 in processedAreas)
          continue;
        auto trans = area.tryMatch(area2);
        if (trans) {
          area2.transforms = area.transforms ~ *trans;
          processedAreas[area2] = true;
          break;
        }
      }
    }
    assert(processedAreas.length > oldProcessedLength);
  }
}

long countBeacons(ScannerArea[] scannerAreas) {
  bool[Coord] beacons;
  foreach (area; scannerAreas) {
    foreach (beacon; area.beacons)
      beacons[beacon.applyReverse(area.transforms)] = true;
  }
  return beacons.length;
}

long maxDistance(ScannerArea[] scannerAreas) {
  Coord[ScannerArea] scannerLocations;
  int distance(Coord a, Coord b) {
    return (a - b).value.reduce!((x, y) => x.abs + y.abs);
  }

  foreach (area; scannerAreas) {
    scannerLocations[area] = Coord([0, 0, 0]).applyReverse(area.transforms);
  }
  int maxDist = 0;
  foreach (area; scannerAreas) {
    foreach (area2; scannerAreas) {
      maxDist = max(maxDist, distance(scannerLocations[area], scannerLocations[area2]));
    }
  }
  return maxDist;
}

void main(string[] args) {
  auto records = args[1].readText.strip.split("\n\n");
  ScannerArea[] scannerAreas;
  foreach (record; records) {
    Coord[] beacons;
    foreach (line; record.splitLines.drop(1)) {
      int[] coords = line.split(",").map!(to!int).array;
      assert(coords.length == 3);
      beacons ~= Coord(coords[0 .. 3]);
    }
    scannerAreas ~= new ScannerArea(beacons);
  }
  syncAreas(scannerAreas);
  writefln("part 1: %d", countBeacons(scannerAreas));
  writefln("part 2: %d", maxDistance(scannerAreas));
}
