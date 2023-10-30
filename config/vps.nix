{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.vps {
  foosteros.profiles = {
    grub = lib.mkDefault true;
  };

  networking.usePredictableInterfaceNames = lib.mkDefault false;
  networking.interfaces.eth0.useDHCP = lib.mkDefault true;
}
