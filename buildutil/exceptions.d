module buildutil.exceptions;

class BuildException : Exception
{
  int status;

  this(int status, string message) {
    super(message);
    this.status = status;
  }
}
