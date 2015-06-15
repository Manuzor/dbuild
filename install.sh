#

dest=$1
alias cp='cp -uv'

function main()
{
  if [ -z "$dest" ]; then
    echo "Need an install destination"
    return 1
  fi

  # Create the destination directory
  mkdir -p "$dest"

  # Source files
  # ============
  mkdir -p "$dest/import"
  cp -r code/. "$dest/import/"
  cp -r thirdParty/pathlib/code/. "$dest/import"

  # Binaries
  # ========
  # Our own output.
  cp -r output/. "$dest"
  # pathlib output.
  cp -r thirdParty/pathlib/output/. "$dest"
}

main $*
