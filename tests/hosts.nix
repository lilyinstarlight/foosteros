{ pkgs, outputs, system, ... }:

with pkgs;

let
  testSystem = configuration: (outputs.lib.baseSystem {
    baseModules = [
      { nixpkgs.config.allowUnfree = false; }
    ];
    modules = [
      configuration
    ];
  }).config.system.build.toplevel;
in

(lib.optionalAttrs (lib.elem system lib.platforms.linux) {
  host-test-minimal = testSystem ../hosts/minimal/configuration.nix;
}) // (lib.optionalAttrs (system == "x86_64-linux") {
  host-test-bina = testSystem ../hosts/bina/configuration.nix;
})
