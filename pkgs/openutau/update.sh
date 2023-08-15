#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix jq common-updater-scripts

set -euo pipefail

nixpkgs="$(git rev-parse --show-toplevel || (printf 'Could not find root of nixpkgs repo\nAre we running from within the nixpkgs git repo?\n' >&2; exit 1))"

stripwhitespace() {
    sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

nixeval() {
    nix --extra-experimental-features nix-command eval --json --impure -f "$nixpkgs" "$1" | jq -r .
}

nixbuildscript() {
    nix --extra-experimental-features nix-command build --impure -f "$nixpkgs" "$1" --no-link --print-out-paths
}

findpath() {
    path="$(nix --extra-experimental-features nix-command eval --json --impure -f "$nixpkgs" "$1.meta.position" | jq -r . | cut -d: -f1)"
    outpath="$(nix --extra-experimental-features nix-command eval --json --impure --expr "builtins.fetchGit \"$nixpkgs\"")"

    if [ -n "$outpath" ]; then
        path="${path/$(echo "$outpath" | jq -r .)/$nixpkgs}"
    fi

    echo "$path"
}

attr="${UPDATE_NIX_ATTR_PATH:-openutau}"
version="$(cd "$nixpkgs" && list-git-tags --pname="$(nixeval "$attr".pname)" --attr-path="$attr" | grep '^build/' | sed -e 's|^build/||' | sort -V | tail -n1)"

pkgpath="$(findpath "$attr")"

updated="$(cd "$nixpkgs" && update-source-version "$attr" "$version" --file="$pkgpath" --print-changes | jq -r length)"

if [ "$updated" -eq 0 ]; then
    echo 'update.sh: Package version not updated, nothing to do.'
    exit 0
fi

"$(cd "$(dirname "$pkgpath")" && "$(nixbuildscript "$attr.fetch-deps")" "$(dirname "$pkgpath")/deps.nix")"
