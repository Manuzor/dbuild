import dbuild;
import dbuild.toolchain.dmd;

import io = std.stdio;
import std.array : array;

// Make this D file a build script.
mixin BuildScript;

Path code = Path("code");
Path thirdParty = Path("thirdParty");
auto pathlibPath() {
  return thirdParty ~ "pathlib";
}

@Rule("lib")
class Lib
{
  auto tc = new DmdToolchain();

  void build() {
    log.info("Building `lib`.");
    auto opts = ToolchainOptions();
    opts.arch = Arch.x86_64;
    opts.outFilePath = Path("output2") ~ "lib";
    opts.importPaths ~= code;
    opts.importPaths ~= pathlibPath ~ "code";
    auto files = Path().glob("*.d").filter!(a => a != Path("build.d")).array;
    files ~= pathlibPath ~ "output" ~ "pathlib.lib";
    tc.build(opts, files);
  }
}

@Rule("app")
@Dependencies(["lib"])
class App
{
  auto tc = new DmdToolchain();

  void build() {
    log.info("Building `app`.");
  }
}

@Rule("installer")
@Dependencies(["lib", "app"])
class Installer
{
  void build() {
    log.info("Building `installer`.");
  }
}
