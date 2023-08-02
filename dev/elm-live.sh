#!/bin/sh

set -e

cd "$(dirname "$0")/../frontend"

nix run nixpkgs#elmPackages.elm-live -- src/Main.elm --start-page=index.html -- --output=elm.js "$@"
