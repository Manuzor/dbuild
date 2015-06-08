module buildutil.script.rules;

struct Rule
{
  string name = null;
}

bool isValid(in ref Rule r) {
  return r.name != null;
}

struct Dependencies
{
  string[] rules = null;
}

bool isValid(in ref Dependencies d) {
  return d.rules != null;
}

package interface IRule
{
  void configure(string[] args);
  void build();
}

package template RuleWrapper(T)
{
  class RuleWrapper : IRule
  {
    T impl;

    this() {
      impl = new T();
    }

    override void configure(string[] args) {
      static if(__traits(compiles, impl.configure(args))) {
        impl.configure(args);
      }
      else static if(__traits(compiles, impl.configure())) {
        impl.configure();
      }
    }

    override void build() {
      static assert(__traits(compiles, impl.build()));
      impl.build();
    }
  }
}
