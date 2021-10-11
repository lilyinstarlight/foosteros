{ pkgs, outputs, system, ... }:

with pkgs;

let
  testSystem = configuration: (outputs.lib.baseSystem {
    modules = [
      { nixpkgs.config.allowUnfree = false; }
      configuration
    ];
  }).config.system.build.toplevel;
in

(lib.optionalAttrs (lib.elem system lib.platforms.linux) {
  minimal-config = testSystem ../hosts/minimal/configuration.nix;
}) // (lib.optionalAttrs (system == "x86_64-linux") {
  bina-config = testSystem ../hosts/bina/configuration.nix;
})
