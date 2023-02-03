{ config, lib, pkgs, ... }:

{
  imports = [
    ./disks.nix
    ./hardware.nix

    ../../config/lily.nix
  ];

  networking.hostName = "minimal";

  services.resolved.dnssec = "false";

  home-manager.users.lily = {
    home.stateVersion = "23.05";
  };

  system.stateVersion = "23.05";
}
