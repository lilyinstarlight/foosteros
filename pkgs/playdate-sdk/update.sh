#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq common-updater-scripts

set -euo pipefail

nixpkgs="$(git rev-parse --show-toplevel || (printf 'Could not find root of nixpkgs repo\nAre we running from within the nixpkgs git repo?\n' >&2; exit 1))"

attr="${UPDATE_NIX_ATTR_PATH:-playdate-sdk}"
version="$(curl -sSL 'https://panic.com/updates/soapbox.php?app=Playdate%20Simulator&appver=0.0.0&appbuild=0&platform=linux&os=0.0.0&mas=0' | jq -r .ID | sed -e 's|^sdk-||')"

(cd "$nixpkgs" && update-source-version "$attr" "$version")
