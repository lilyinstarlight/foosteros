{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    sbctl
  ];

  boot.lanzaboote = {
    enable = true;
    enrollKeys = true;
    pkiBundle = "/etc/secureboot";
  };
}
