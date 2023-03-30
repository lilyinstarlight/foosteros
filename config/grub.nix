{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.grub {
  boot.loader.grub.devices = lib.mkDefault [ config.system.devices.rootDisk ];
}
