{ pkgs, self, ... }:

with pkgs;

let
  testSystem = configuration: (configuration.override (args: {
    baseModules = [
      { nixpkgs.config.allowUnfree = false; }
    ] ++ (args.baseModules or []);
  })).config.system.build.toplevel;

  testInstaller = configuration: (configuration.override (args: {
    baseModules = [
      { nixpkgs.config.allowUnfree = false; }
    ] ++ (args.baseModules or []);
  })).config.system.build.installer;
in

lib.listToAttrs (lib.flatten (
  map (cfg: [ { name = "host-test-" + cfg.config.networking.hostName; value = testSystem cfg; } ] ++
    lib.optionals (cfg.config.system.build ? installer) [ { name = "installer-test-" + cfg.config.networking.hostName; value = testInstaller cfg; } ])
  (lib.unique (lib.filter (cfg: cfg.pkgs.stdenv.hostPlatform.system == pkgs.stdenv.hostPlatform.system) (lib.collect
    (cfg: cfg ? config && cfg.config ? system && cfg.config.system ? build && cfg.config.system.build ? toplevel)
    self.nixosConfigurations
  )))
))
