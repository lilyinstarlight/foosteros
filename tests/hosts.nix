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
  })).config.system.build.installerSystem.config.system.build.toplevel;
in

lib.listToAttrs (lib.flatten (
  map (cfg: [ { name = "host-" + cfg.config.networking.hostName; value = testSystem cfg; } ] ++
    lib.optionals (cfg.config.system.build ? installer) [ { name = "installer-" + cfg.config.networking.hostName; value = testInstaller cfg; } ])
  (lib.unique (lib.filter (cfg: cfg.pkgs.stdenv.buildPlatform.system == pkgs.stdenv.buildPlatform.system) (lib.collect
    (cfg: cfg ? config && cfg.config ? system && cfg.config.system ? build && cfg.config.system.build ? toplevel)
    self.nixosConfigurations
  )))
))
