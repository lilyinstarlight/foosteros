{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.sd-boot {
  boot.loader.systemd-boot.enable = lib.mkDefault true;
}
