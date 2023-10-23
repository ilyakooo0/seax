#!/bin/sh

set -e

cd "$(dirname "$0")/../frontend"

if [[ -z $(command -v nix) ]] && [[ -z $(command -v elm-live) ]]; then
  echo "Please install either 'nix' or 'elm-live'" && exit 1
fi

command -v nix && nix run nixpkgs#elmPackages.elm-live -- src/Main.elm --start-page=index.html -- --debug --output=elm.js "$@"
command -v elm-live && elm-live src/Main.elm --start-page=index.html -- --debug --output=elm.js "$@"
