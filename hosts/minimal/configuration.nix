{ config, lib, pkgs, ... }:

{
  imports = [
    ./disks.nix
    ./hardware.nix
  ];

  networking.hostName = "minimal";

  foosteros.profiles.lily = true;

  system.stateVersion = "26.05";
}
