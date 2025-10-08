{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.fprint {
  services.fprintd.enable = true;

  preservation.preserveAt = lib.mkIf config.preservation.enable {
    ${config.system.devices.preservedState}.directories = [
      "/var/lib/fprint"
    ];
  };
}
