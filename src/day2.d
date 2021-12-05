import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;

void maneuver(const string[] commands, int part) {
  int depth = 0;
  int horiz = 0;
  int aim = 0;
  const bool revised = part > 1;

  foreach (line; commands) {
    const instr = line.split(" ");
    const string cmd = instr[0];
    const int arg = to!int(instr[1]);
    final switch (cmd) {
      case "forward":
        horiz += arg;
        if (revised)
          depth += aim * arg;
        break;
      case "up":
        if (revised)
          aim -= arg;
        else
          depth -= arg;
        break;
      case "down":
        if (revised)
          aim += arg;
        else
          depth += arg;
        break;
    }
  }
  writefln("part %d: %d", part, depth * horiz);
}

void main(string[] args) {
  const commands = args[1].readText.splitLines;
  maneuver(commands, 1);
  maneuver(commands, 2);
}
