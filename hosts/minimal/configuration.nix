{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../config/lily.nix
  ];

  networking.hostName = "minimal";

  services.resolved.dnssec = "false";

  home-manager.users.lily = {
    home.stateVersion = "22.11";
  };

  system.stateVersion = "22.11";
}
