{ pkgs }:

let

  plugins = pkgs.callPackage ./generated.nix {
    inherit (pkgs) fetchFromGitHub;
  };

in

plugins
