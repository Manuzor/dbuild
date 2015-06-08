import buildutil;
import buildutil.compiler.dmd;

import std.array : array;

// Make this D file a build script.
mixin BuildScript;


@Rule("lib")
class Lib
{
  auto compiler = new DmdCompiler();

  void build() {
    auto opts = CompilerOptions();
    compiler.compile(opts, Path().glob("code/*.d").array);
  }
}

@Rule("app")
@Dependencies(["lib"])
class App
{
  auto compiler = new DmdCompiler();

  void build() {
    import io = std.stdio;
    io.writeln("Hello from the `app` rule!");
  }
}
