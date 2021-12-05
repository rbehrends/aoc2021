import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;

import bits;

void main(string[] args) {
  const input = args[1].readText.strip.splitLines;
  const packetList = input.map!((line) =>
      line.split("")
        .map!((x) => to!int(x, 16))
        .map!((x) => format("%04b", x))
        .join
  ).array;
  foreach (bitstring; packetList) {
    auto packet = new BitParser(bitstring).parsePacket();
    writeln(lispify(packet));
    writefln("part 1: %d", versionSum(packet));
    writefln("part 2: %d", eval(packet));
  }
}