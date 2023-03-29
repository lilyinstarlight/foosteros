{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.secureboot {
  environment.systemPackages = with pkgs; [
    sbctl
  ];

  boot.loader.systemd-boot.enable = false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };
}
