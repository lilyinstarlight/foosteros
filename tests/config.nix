{ pkgs, outputs, ... }:

let
  testSystem = configuration: (outputs.lib.baseSystem {
    modules = [
      { nixpkgs.config.allowUnfree = false; }
      configuration
    ];
  }).config.system.build.toplevel;
in

{
  minimal = testSystem ../hosts/minimal/configuration.nix;

  bina = testSystem ../hosts/bina/configuration.nix;
}
