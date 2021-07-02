{ pkgs, outputs, ... }:

{
  bina = (outputs.lib.baseSystem {
    modules = [
      { nixpkgs.config.allowUnfree = false; }
      ../hosts/bina/configuration.nix
    ];
  }).config.system.build.toplevel;
}
