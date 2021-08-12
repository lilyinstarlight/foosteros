{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../config/base.nix

    ../../config/lily.nix
  ];

  networking.hostName = "minimal";

  services.resolved.dnssec = "false";

  system.stateVersion = "21.05";
}
