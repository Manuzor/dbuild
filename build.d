import buildutil;
import buildutil.toolchain.dmd;

import io = std.stdio;
import std.array : array;

// Make this D file a build script.
mixin BuildScript;


@Rule("lib")
class Lib
{
  auto tc = new DmdToolchain();

  void build() {
    auto opts = ToolchainOptions();
    opts.arch = Arch.x86_64;
    opts.outFilePath = Path("output") ~ "lib";
    opts.importPaths ~= Path("pathlib") ~ "code";
    tc.build(opts, Path().glob("*.d").filter!(a => a != Path("build.d")).array);
  }
}

@Rule("app")
@Dependencies(["lib"])
class App
{
  auto tc = new DmdToolchain();

  void build() {
    io.writeln("Hello from the `app` rule!");
  }
}
