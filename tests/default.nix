{ pkgs, ... }:

{
  config = pkgs.callPackage ./config.nix {};
  pkgs = pkgs.callPackage ./pkgs.nix {};
}
