{ pkgs, outputs, ... }:

let
  config-tests = import ./config.nix { inherit pkgs outputs; };
  pkgs-tests = import ./pkgs.nix { inherit pkgs; };
in

config-tests // pkgs-tests
