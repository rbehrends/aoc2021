import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;

const ops = ["+", "*", "min", "max", "lit", ">", "<", "="];

abstract class Packet {
public:
  int ver;
  this(int ver) {
    this.ver = ver;
  }

  long eval();
  int versionSum();
}

class Literal : Packet {
  long value;
public:
  this(int ver, long value) {
    super(ver);
    this.value = value;
  }
  override long eval() { return value; }
  override int versionSum() { return ver; }
  override string toString() { return format("%d", value); }
}

class Operator : Packet {
  Packet[] subPackets;
  int type;
public:
  this(int ver, int type, Packet[] subPackets = []) {
    super(ver);
    this.type = type;
    this.subPackets = subPackets;
  }

  void addPacket(Packet packet) { subPackets ~= packet; }

  override string toString() {
    return "(" ~ ops[type] ~ " " ~ subPackets.map!q{a.toString}.join(" ") ~ ")";
  }

  override long eval() {
    long[] args = subPackets.map!q{a.eval}.array;
    switch (type) {
      case 0: return args.reduce!((a, b) => a + b);
      case 1: return args.reduce!((a, b) => a * b);
      case 2: return args.reduce!min;
      case 3: return args.reduce!max;
      case 5: return args[0] > args[1] ? 1 : 0;
      case 6: return args[0] < args[1] ? 1 : 0;
      case 7: return args[0] == args[1] ? 1 : 0;
      default: assert(false);
    }
  }

  override int versionSum() {
    return ver + subPackets.map!q{a.versionSum}.sum;
  }
}

class BitParser {
  string bitstring;
  size_t pos;
  int read(int nbits) {
    pos += nbits;
    return to!int(bitstring[pos - nbits .. pos], 2);
  }

public:
  this(string bitstring) {
    this.bitstring = bitstring;
    pos = 0;
  }

  Packet parsePacket() {
    auto ver = read(3);
    auto type = read(3);
    if (type == 4) {
      long value = 0;
      int piece;
      do {
        piece = read(5);
        value = (value << 4) | (piece & 0b1111);
      } while (piece & 0b10000);
      return new Literal(ver, value);
    } else {
      auto packet = new Operator(ver, type);
      if (read(1)) {
        foreach (_; 0 .. read(11))
          packet.addPacket(parsePacket());
      } else {
        const len = read(15), end = pos + len;
        while (pos < end)
          packet.addPacket(parsePacket());
      }
      return packet;
    }
  }
}

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
    writeln(packet);
    writefln("part 1: %d", packet.versionSum);
    writefln("part 2: %d", packet.eval);
  }
}