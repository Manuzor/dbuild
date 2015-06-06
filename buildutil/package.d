module buildutil;

public import pathlib;

enum Arch
{
  x86,
  x86_64
}

struct CompilerOptions
{
  Arch arch = Arch.x86;
}

interface Compiler
{
  abstract int compile(in ref CompilerOptions options, Path[] files);
}
