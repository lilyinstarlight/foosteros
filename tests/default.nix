{ ... } @ args:

let
  config-tests = import ./config.nix args;
  pkgs-tests = import ./pkgs.nix args;
in

config-tests // pkgs-tests
