{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.fwupd {
  services.fwupd.enable = true;
}
