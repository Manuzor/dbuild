module buildutil.script.buildscript;

template Resolve(T)
{
  alias Resolve = T;
}

mixin template BuildScriptImpl(alias mod)
{
  int main(string[] args) {
    import io = std.stdio;
    io.writeln("Hellooo!");

    IRule[string] rules;

    foreach(m; __traits(allMembers, mod)) {
      static if(!__traits(compiles, typeof(__traits(getMember, mod, m)))) {
        static if(__traits(compiles, Resolve!(__traits(getMember, mod, m)))) {
          alias Class = Resolve!(__traits(getMember, mod, m));
          static if(is(Class == class)) {
            pragma(msg, "Class found! " ~ Class.stringof);
            foreach(uda; __traits(getAttributes, Class)) {
              static if(is(typeof(uda) == Rule)) {
                pragma(msg, "+++ Found rule `" ~ uda.name ~ "`: class " ~ Class.stringof);
                rules[uda.name] = new RuleWrapper!Class();
              }
            }
          }
        }
      }
    }

    io.writefln("Rules: %(\n  %s: %)", rules);

    foreach(n, r; rules) {
      r.configure(args);
    }

    foreach(n, r; rules) {
      r.build();
    }
    return 0;
  }
}

mixin template BuildScript()
{
  class _Dummy {}
  mixin BuildScriptImpl!(__traits(parent, _Dummy));
}