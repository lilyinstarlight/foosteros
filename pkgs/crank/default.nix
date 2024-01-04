{ lib, runCommand, rustPlatform, fetchFromGitHub, makeWrapper, cargo, gcc-arm-embedded, playdate-sdk, xdg-utils, writeScript, unstableGitUpdater }:

rustPlatform.buildRustPackage rec {
  pname = "crank";
  version = "unstable-2023-09-16";

  src = fetchFromGitHub {
    owner = "pd-rs";
    repo = pname;
    rev = "f46cda4a2dd028d5580d89268975fcb21f6f0eb5";
    hash = "sha256-+L1/ZwMPV7HqTK9o3Tczj2KBhBrXNM/5LBLRSqfipxI=";
  };

  cargoPatches = [
    ./crank-fix-no-rustup.patch
  ];

  # TODO: bug upstream to actually make sure version numbers in Cargo.lock get updated when bumping Cargo.toml
  postUnpack = ''
    sed -i '$!N;s/^\(name = "crankstart-cli"\nversion =\) "[^"]*"$/\1 "'"$(sed -n '/^version\s*=/ s/^version = "\([^"]*\)"$/\1/p' source/Cargo.toml)"'"/;P;D' source/Cargo.lock
  '';

  cargoHash = "sha256-xu7/zXrqAZAr4mzl9IeupCAkKnxlf4i30XbhCY7zj7I=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = let
    # TODO: find better way to override sysroot for rust src
    rustLibSrc = runCommand "rust-lib-src" {} ''
      mkdir -p $out
      ln -s ${rustPlatform.rustLibSrc} $out/library
    '';
  in ''
    wrapProgram $out/bin/crank \
      --prefix PATH : '${lib.makeBinPath [ cargo gcc-arm-embedded playdate-sdk xdg-utils ]}' \
      --set RUSTC_BOOTSTRAP 1 \
      --set __CARGO_TESTS_ONLY_SRC_ROOT '${rustLibSrc}' \
      --set PLAYDATE_SDK_PATH '${playdate-sdk}/sdk'
  '';

  passthru.updateScript = writeScript "update-crank-unstable.sh" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p nix jq git

    set -euo pipefail

    nixpkgs="$(git rev-parse --show-toplevel || (printf 'Could not find root of nixpkgs repo\nAre we running from within the nixpkgs git repo?\n' >&2; exit 1))"

    stripwhitespace() {
        sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
    }

    nixeval() {
        nix --extra-experimental-features nix-command eval --json --impure -f "$nixpkgs" "$1" | jq -r .
    }

    vendorhash() {
        (nix --extra-experimental-features nix-command build --impure -f "$nixpkgs" --no-link "$1" 2>&1 >/dev/null | tail -n3 | grep -F got: | cut -d: -f2- | stripwhitespace) 2>/dev/null || true
    }

    findpath() {
        path="$(nix --extra-experimental-features nix-command eval --json --impure -f "$nixpkgs" "$1.meta.position" | jq -r . | cut -d: -f1)"
        outpath="$(nix --extra-experimental-features nix-command eval --json --impure --expr "builtins.fetchGit \"$nixpkgs\"")"

        if [ -n "$outpath" ]; then
            path="''${path/$(echo "$outpath" | jq -r .)/$nixpkgs}"
        fi

        echo "$path"
    }

    ${lib.escapeShellArgs (unstableGitUpdater {})}

    attr="''${UPDATE_NIX_ATTR_PATH:-crank}"

    pkgpath="$(findpath "$attr")"

    if git diff --exit-code --quiet "$pkgpath"; then
        echo 'update-crank-unstable.sh: Package version not updated, nothing to do.'
        exit 0
    fi

    curhash="$(nixeval "$attr.cargoDeps.outputHash")"
    newhash="$(vendorhash "$attr.cargoDeps")"

    if [ -n "$newhash" ] && [ "$curhash" != "$newhash" ]; then
        sed -i -e "s|\"$curhash\"|\"$newhash\"|" "$pkgpath"
    else
        echo 'update-crank-unstable.sh: New cargoHash same as old cargoHash, nothing to do.'
    fi
  '';

  passthru.dependsUnfree = true;

  meta = with lib; {
    description = "A cargo wrapper for creating games for the Playdate handheld gaming system";
    license = licenses.mit;
    homepage = "https://github.com/rtsuk/crank";
    maintainers = with maintainers; [ lilyinstarlight ];
    platforms = platforms.linux;
  };
}
