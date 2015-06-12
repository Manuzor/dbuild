#

dest=$1
alias cp='cp -uv'

function main()
{
  if [ -z "$dest" ]; then
    echo "Need an install destination"
    return 1
  fi

  mkdir -p "$dest/import"
  cp -r code/. "$dest/import/"
  cp -r thirdParty/pathlib/code/. "$dest/import"

  mkdir -p "$dest/lib"
  cp -r output/lib/. "$dest/lib"
  cp thirdParty/pathlib/output/pathlib.lib "$dest/lib"

  mkdir -p "$dest/bin"
  cp -r output/bin/. "$dest/bin"
}

main $*
