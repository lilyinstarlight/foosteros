{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../config/lily.nix
  ];

  networking.hostName = "minimal";

  services.resolved.dnssec = "false";

  system.stateVersion = "22.05";
}
