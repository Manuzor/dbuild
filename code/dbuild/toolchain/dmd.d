module dbuild.toolchain.dmd;
import dbuild;

import std.process;
import std.array;
import std.format : format;

class DmdToolchain : Toolchain
{
  string dmdExecutable = null;

  this() {
    // TODO Try harder than that to find dmd.
    dmdExecutable = "dmd";
  }

  string[] makeFlags(in ref ToolchainOptions options) {
    string[] flags;

    if(options.verbose) {
      flags ~= "-v";
    }

    final switch(options.arch) {
      case Arch.Default:
        break;
      case Arch.x86:
        flags ~= "-m32";
        break;
      case Arch.x86_64:
        flags ~= "-m64";
        break;
    }

    final switch(options.debugSymbols) {
      case DebugSymbols.No:
        break;
      case DebugSymbols.Yes:
        flags ~= "-g";
        break;
      case DebugSymbols.C:
        flags ~= "-gc";
        break;
    }

    if(options.objectFilePath.data) {
      flags ~= format("-od%s", options.objectFilePath.normalizedData);
    }

    if(options.preserveSourceFilePaths) {
      flags ~= "-op";
    }

    if(options.outFilePath.data) {
      flags ~= format("-of%s", options.outFilePath.normalizedData);
    }

    // Finally, add all user-defined flags
    // Note: dmd ignores empty switches.
    flags ~= options.cflags;
    if(options.lflags && !options.lflags.empty) {
      flags ~= format("-L%-(%s;%)", options.lflags);
    }

    return flags;
  }

  override void build(in ref ToolchainOptions options, Path[] files) {
    assert(!files.empty, "No source files given.");
    auto flags = makeFlags(options);

    auto cmd = ["dmd"]
             ~ flags
             ~ files.map!(a => cast(string)a.normalizedData).array;
    io.writefln("Executing: %s", cmd);
    auto status = spawnProcess(cmd).wait();
    if(status != 0) {
      throw new BuildException(status, "Executing dmd failed with status code %s.".format(status));
    }
  }
}
