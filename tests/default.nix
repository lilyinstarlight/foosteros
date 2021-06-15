{ pkgs, ... }:

let
  config-tests = import ./config.nix { inherit pkgs; };
  pkgs-tests = import ./pkgs.nix { inherit pkgs; };
in

config-tests // pkgs-tests
