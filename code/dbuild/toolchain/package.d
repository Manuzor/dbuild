module dbuild.toolchain;
import dbuild;

import std.array;

enum Arch
{
  Default,
  x86,    // dmd: -m32
  x86_64  // dmd: -m64
}

enum DebugSymbols
{
  No,
  Yes,  // dmd: -g
  C,    // dmd: -gc
}

mixin template CommonOptionsMixin()
{
  Arch arch;             // dmd: -m32 or -m64
  bool verbose = false;  // dmd: -v
}

/// Usage:
///   auto lo1 = LinkerOptions();
///   auto lo2 = CompilerOptions(Arch.x86);
///   lo1.copyCommonOptionsFrom(lo2);
void copyCommonOptionsFrom(To, From)(auto ref To to, in auto ref From from) {
  to.arch = from.arch;
  to.verbose = from.verbose;
}

mixin template CompilerSpecificOptions()
{
  Path objectFilePath = Path(null);      // dmd: -od
  bool preserveSourceFilePaths = false;  // dmd: -op
  Path[] importPaths;                    // dmd: -I
  Path[] stringImportPaths;              // dmd: -J
  DebugSymbols debugSymbols;             // dmd: -g or -gc

  /// Raw compiler flags
  /// For better portability, you should use this field as little as possible.
  string[] cflags;
}

void copyCompilerSpecificOptionsFrom(To, From)(auto ref To to, in auto ref From from) {
  to.objectFilePath = from.objectFilePath;
  to.preserveSourceFilePaths = from.preserveSourceFilePaths;
  to.cflags = from.cflags.dup;
}

mixin template LinkerSpecificOptions()
{
  /// The path of the lib/dll/exe.
  Path outFilePath = Path(null);  // dmd: -of

  /// Raw linker flags.
  /// For better portability, you should use this field as little as possible.
  string[] lflags; // dmd: -L
}

void copyLinkerSpecificOptionsFrom(To, From)(auto ref To to, in auto ref From from) {
  to.outFilePath = from.outFilePath;
  to.lflags = from.lflags.dup;
}

struct CommonOptions
{
  mixin CommonOptionsMixin;
}

struct CompilerOptions
{
  mixin CommonOptionsMixin;
  mixin CompilerSpecificOptions;
}

struct LinkerOptions
{
  mixin CommonOptionsMixin;
  mixin LinkerSpecificOptions;
}

struct ToolchainOptions
{
  mixin CommonOptionsMixin;
  mixin CompilerSpecificOptions;
  mixin LinkerSpecificOptions;

  this(in ref CompilerOptions options) {
    this.copyCommonOptionsFrom(options);
    this.copyCompilerSpecificOptionsFrom(options);
  }

  this(in ref LinkerOptions options) {
    this.copyCommonOptionsFrom(options);
    this.copyLinkerSpecificOptionsFrom(options);
  }

  this(in ref CompilerOptions compilerOpts, in ref LinkerOptions linkerOpts) {
    // TODO Make sure the common part in compilerOpts matches linkerOpts
    this.copyCommonOptionsFrom(compilerOpts);
    this.copyCompilerSpecificOptionsFrom(compilerOpts);
    this.copyLinkerSpecificOptionsFrom(linkerOpts);
  }
}

interface Compiler
{
  void compile(in ref CompilerOptions options, Path[] files);
}

interface Linker
{
  void link(in ref LinkerOptions options, Path[] objectFiles);
}

interface Toolchain
{
  void build(in ref ToolchainOptions options, Path[] files);
}
