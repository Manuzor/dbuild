module dbuild.app;

import dbuild;
import io = std.stdio;

class ArgsException : Exception
{
  int status;

  this(int status, string message) {
    super(message);
    this.status = status;
  }
}

struct Args
{
  // Options
  bool verbose;

  // Required Args
  Path sourcePath;


  static string usage() {
    import core.runtime;
    return q"{
Usage: %s [option...] sourcePath
Options:}".format(Path(Runtime.args[0]).name);
  }

  static Args parse(string[] args) {
    import std.getopt;
    auto result = Args();

    with(result) {
      auto helpInfo = getopt(args,
        "verbose|v", "Whether to be verbose or not.", &verbose
      );

      if(helpInfo.helpWanted) {
        defaultGetoptPrinter(usage(), helpInfo.options);
        throw new ArgsException(0, "Parsing commandline options failed.");
      }

      args = args[1..$];
      if(args.empty) {
        defaultGetoptPrinter(usage(), helpInfo.options);
        throw new ArgsException(1, "Missing required 'sourcePath' argument.");
      }

      sourcePath = Path(args[0]);
    }
    return result;
  }
}

int main(string[] strargs) {
  log.infof("Working dir: %s", cwd());
  Args args;
  try {
    args = Args.parse(strargs);
  }
  catch(ArgsException e) {
    if(e.status == 0) {
      return 0;
    }
    log.errorf("%s".format(e));
    return e.status;
  }
  if(!args.sourcePath.exists) {
    log.errorf("Given path to source dir does not exist: %s", args.sourcePath);
  }
  auto buildScript = args.sourcePath;
  if(buildScript.isDir) {
    buildScript ~= "build.d";
  }
  if(!buildScript.exists) {
    log.errorf("Build script does not exist: %s", buildScript);
  }

  auto installDir = currentExePath().parent.parent;
  log.infof("Install dir: %s".format(installDir));
  auto commonLibDir = installDir ~ "lib";
  auto commonImportDir = installDir ~ "import";
  auto temp = Path(".dbuild");

  log.info("+++ Building script %s +++".format(buildScript));
  auto dmd = new DmdToolchain();
  auto opts = ToolchainOptions();
  opts.verbose = args.verbose;
  opts.arch = Arch.x86_64;
  //opts.dryRun = true;
  opts.debugSymbols = DebugSymbols.C;
  opts.outFilePath = temp ~ "build";
  opts.objectFilePath = temp;
  opts.importPaths = [
     commonImportDir,
  ];
  auto files = [buildScript]
             ~ commonLibDir.glob("*.lib").array;
  dmd.build(opts, files);
  if(opts.dryRun) {
    return 0;
  }
  auto buildExecutable = opts.outFilePath;
  if(!buildExecutable.exists) {
    buildExecutable = buildExecutable.parent ~ "%s.exe".format(buildExecutable.stem);
  }
  buildExecutable = buildExecutable.resolved();
  import std.process;
  log.infof("Running build: %s", buildExecutable);
  return spawnProcess(buildExecutable.normalizedData).wait();
}
