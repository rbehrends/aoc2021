#!/usr/bin/env python

from waflib import Configure
from waflib.Tools import compiler_d
import os

Configure.autoconfig = True

compiler_d.d_compiler["default"] = ["ldc2", "dmd", "gdc"]

# Hide Building/Entering/completion messages

from waflib import Logs
from waflib import Context
def interceptLogInfo(msg, *args, **kw):
  if msg.startswith("Waf: "):
    return
  if msg.startswith("%r finished successfully "):
    return
  oldLogInfo(msg, *args, **kw)
oldLogInfo = Logs.info
Logs.info = interceptLogInfo

# Save horizontal space

Context.Context.line_just = 1


def options(opt):
  opt.add_option("--quiet", action="store_true", dest="quiet",
    help="suppress build output")
  opt.add_option("--opt", action="store_true", dest="optimize",
    help="optimize code")
  opt.add_option("--unittest", action="store_true", dest="unittest",
    help="build with unit tests enabled")
  opt.add_option("--prefix", action="store", dest="prefix", default=".",
    help="installation prefix [default: '.']")
  opt.load("compiler_d")

def quiet(ctx):
  from waflib import Logs
  import logging
  if ctx.options.quiet:
      Logs.log.level = logging.ERROR

def configure(cnf):
  cnf.load("compiler_d")

def build(bld):
  bld.cwd = "."
  if bld.options.optimize:
    if bld.env.COMPILER_D == "dmd":
      bld.env.append_value("DFLAGS", "-O")
      bld.env.append_value("DFLAGS", "-inline")
      bld.env.append_value("DFLAGS", "-release")
    else: # ldc or gdc
      bld.env.append_value("DFLAGS", "-O")
      bld.env.append_value("DFLAGS", "-release")
  if bld.options.unittest:
    bld.env.append_value("DFLAGS", "-unittest")
  bld.env.append_value("DFLAGS", "-g")
  bld.env.append_value("LINKFLAGS", "-g")

  # So that binaries are created outside the build directory
  bindir = bld.path.make_node("bin")
  bld.objects(target="common",
    source=bld.path.ant_glob("lib/*.d"),
    includes="lib")

  for progsrc in bld.path.ant_glob("src/day*.d"):
    progname, ext = os.path.splitext(os.path.basename(progsrc.relpath()))
    bld.program(features="d",
      target=bindir.make_node(progname),
      source=[ progsrc ],
      includes="src lib",
      use="common")


def distclean(ctx):
  from waflib import Scripting
  import shutil
  shutil.rmtree("bin", ignore_errors=True)
  Scripting.distclean(ctx)
