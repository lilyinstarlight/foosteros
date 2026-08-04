{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.firewalld {
  services.firewalld.enable = true;
  networking.nftables.enable = true;
}
