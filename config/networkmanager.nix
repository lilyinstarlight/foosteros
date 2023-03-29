{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.networkmanager {
  networking.networkmanager = {
    enable = true;
    wifi.powersave = true;
    unmanaged = [
      "interface-name:vir*"
    ];
  };
}
