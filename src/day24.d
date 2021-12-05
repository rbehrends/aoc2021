import std.stdio;
import std.file;
import std.string;
import std.conv;
import std.algorithm;
import std.array;
import std.range;

struct State {
  long[4] reg;
}

enum Op {
  inp,
  add,
  mul,
  div,
  mod,
  eql
}

int max;

struct Instr {
  Op op;
  int arg1, arg2;
  bool immediateArg;
  void execute(ref State state, int input = 0) {
    void result(long val) {
      state.reg[arg1] = val;
    }

    @property long dest() {
      return state.reg[arg1];
    }

    @property long src() {
      return immediateArg ? arg2 : state.reg[arg2];
    }

    final switch (op) {
      case Op.inp:
        result(input);
        break;
      case Op.add:
        result(dest + src);
        break;
      case Op.mul:
        result(dest * src);
        break;
      case Op.div:
        assert(src > 0);
        auto tmp = dest;
        if (tmp < 0)
          result(-(-tmp) / src);
        result(dest / src);
        break;
      case Op.mod:
        assert(src > 0);
        result(dest % src);
        break;
      case Op.eql:
        result(dest == src ? 1 : 0);
        break;
    }
  }
}


long findBest(alias traversalOrder)(Instr[] code, int pc, State state,
             ref bool[State][] seen, long input, int depth) {
  while (pc < code.length && code[pc].op != Op.inp)
    code[pc++].execute(state);
  auto zreg = state.reg[3];
  if (pc == code.length)
    return zreg == 0 ? input : -1;
  if (state in seen[depth])
    return -1;
  seen[depth][state] = true;
  input *= 10;
  foreach (digit; traversalOrder) {
    code[pc].execute(state, digit);
    auto result = findBest!(traversalOrder)(code, pc + 1, state, seen,
        input + digit, depth + 1);
    if (result >= 0) {
      return result;
    }
  }
  return -1;
}

long findBest(alias traversalOrder)(Instr[] code, int pc) {
  auto seen = new bool[State][](code.count!((ref instr) => instr.op == Op.inp));
  return findBest!(traversalOrder)(code, pc, State(), seen, 0, 0);
}

void main(string[] args) {
  auto lines = args[1].readText.splitLines;
  Instr[] code;
  auto ops = ["inp" : Op.inp, "add" : Op.add, "mul" : Op.mul, "div" : Op.div,
    "mod" : Op.mod, "eql" : Op.eql,];
  auto regs = ["w" : 0, "x" : 1, "y" : 2, "z" : 3,];
  foreach (line; lines) {
    auto parts = line.split();
    Instr instr = {
      op: ops[parts[0]],
      arg1 : regs[parts[1]],
      arg2 : parts.length > 2
        ? (parts[2] in regs
	    ? regs[parts[2]]
	    : to!int(parts[2]))
	: 0,
    immediateArg : parts.length > 2 && !(parts[2] in regs)
    };
    code ~= instr;
  }
  writefln("part 1: %d", findBest!(iota(9, 0, -1))(code, 0));
  writefln("part 2: %d", findBest!(iota(1, 10))(code, 0));
}
