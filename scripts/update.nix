{ nixpkgs ? <nixpkgs>, system ? builtins.currentSystem, pkgs ? import nixpkgs { inherit system; }, ... }@args:

import "${nixpkgs}/maintainers/scripts/update.nix" ({
  predicate = _path: pkg: with pkgs.lib;
    hasPrefix (toString ../.) (head (splitString ":" pkg.meta.position));
  include-overlays = import ../overlays.nix;
} // (removeAttrs args [ "nixpkgs" "system" "pkgs" ]))
