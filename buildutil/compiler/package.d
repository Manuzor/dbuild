module buildutil.compiler;
import buildutil;

enum Arch
{
  x86,
  x86_64
}

struct CompilerOptions
{
  Arch arch = Arch.x86_64;
  Path outFilePath;
}

interface Compiler
{
  abstract int compile(in ref CompilerOptions options, Path[] files);
}
