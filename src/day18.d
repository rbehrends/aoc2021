import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;

// This solution avoids pattern matching and other tree
// operations by representing a tree as an array with
// the nodes in preorder format. While this makes some
// tree operations more complex, others become easier.

// For a more traditional solution, see day18.scala.

struct Node {
  bool isLeaf;
  int value = 0;
}

alias Tree = Node[];

bool explode(ref Tree fish) {
  int depth = 0;
  int nodeEndMarkers = 0;
  for (long i = 0; i + 2 < fish.length; i++) {
    if (!fish[i].isLeaf) {
      depth++;
      nodeEndMarkers <<= 1;
      if (depth > 4 && fish[i + 1].isLeaf && fish[i + 2].isLeaf) {
        for (long j = i - 1; j >= 0; j--) {
          if (fish[j].isLeaf) {
            fish[j].value += fish[i + 1].value;
            break;
          }
        }
        for (long j = i + 3; j < fish.length; j++) {
          if (fish[j].isLeaf) {
            fish[j].value += fish[i + 2].value;
            break;
          }
        }
        fish = replaceSlice(fish, fish[i .. i + 3], [Node(true, 0)]);
        return true;
      }
    } else {
      while (nodeEndMarkers & 1) {
        nodeEndMarkers >>= 1;
        depth--;
      }
      nodeEndMarkers |= 1;
    }
  }
  return false;
}

bool split(ref Tree fish) {
  for (long i = 0; i < fish.length; i++) {
    if (fish[i].isLeaf && fish[i].value >= 10) {
      auto value = fish[i].value;
      fish = fish.replaceSlice(fish[i .. i + 1], [
          Node(false), Node(true, value / 2), Node(true, (value + 1) / 2)
          ]);
      return true;
    }
  }
  return false;
}

void reduceFish(ref Tree fish) {
  while (explode(fish) || split(fish)) {
  }
}

Tree addFish(Tree fish1, Tree fish2) {
  Tree result = Node(false) ~ fish1 ~ fish2;
  reduceFish(result);
  return result;
}

int mag(Tree fish, ref long start) {
  if (fish[start].isLeaf) {
    return fish[start++].value;
  } else {
    start++;
    auto left = mag(fish, start);
    auto right = mag(fish, start);
    return left * 3 + right * 2;
  }
}
int mag(Tree fish) {
  long start = 0;
  return mag(fish, start);
}

Tree parse(string input) {
  Tree result;
  foreach (char ch; input) {
    switch (ch) {
      case '[':
        result ~= Node(false);
        break;
      case ']':
      case ',':
        break;
      case '0': .. case '9':
        result ~= Node(true, (ch - '0').to!byte);
        break;
      default:
        assert(false);
    }
  }
  return result;
}

void main(string[] args) {
  const lines = args[1].readText.splitLines;
  auto fishes = lines.map!(parse).array;
  auto result = fishes.reduce!addFish;
  int maxMag = 0;
  writefln("part 1: %d", result.mag);
  foreach (fish1; fishes) {
    foreach (fish2; fishes) {
      if (fish1 !is fish2)
        maxMag = max(maxMag, addFish(fish1, fish2).mag);
    }
  }
  writefln("part 2: %d", maxMag);
}
