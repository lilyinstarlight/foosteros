{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.bluetooth {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    settings.General.Name = lib.mkDefault
      ((lib.toUpper (lib.substring 0 1 config.networking.hostName)) + (lib.substring 1 (lib.stringLength config.networking.hostName) config.networking.hostName));
  };
}
