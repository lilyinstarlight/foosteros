{ pkgs, outputs, ... }:

{
  minimal = (outputs.lib.baseSystem {
    modules = [
      { nixpkgs.config.allowUnfree = false; }
      ../hosts/minimal/configuration.nix
    ];
  }).config.system.build.toplevel;

  bina = (outputs.lib.baseSystem {
    modules = [
      { nixpkgs.config.allowUnfree = false; }
      ../hosts/bina/configuration.nix
    ];
  }).config.system.build.toplevel;
}
