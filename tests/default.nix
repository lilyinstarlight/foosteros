{ ... } @ args:

let
  hosts-tests = import ./hosts.nix args;
  pkgs-tests = import ./pkgs.nix args;
in

hosts-tests // pkgs-tests // {}
