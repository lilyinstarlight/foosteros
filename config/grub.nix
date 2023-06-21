{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.grub {
  boot.loader.grub.device = lib.mkDefault config.system.devices.rootDisk;
}
