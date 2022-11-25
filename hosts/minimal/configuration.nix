{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../config/lily.nix
  ];

  networking.hostName = "minimal";

  services.resolved.dnssec = "false";

  home-manager.users.lily = {
    home.stateVersion = "23.05";
  };

  system.stateVersion = "23.05";
}
