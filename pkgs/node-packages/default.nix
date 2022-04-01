{ pkgs, nodejs, stdenv }:

let
  super = import ./composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };
  self = super // {};
in self
