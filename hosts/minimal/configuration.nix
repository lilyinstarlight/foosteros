{ config, lib, pkgs, ... }:

{
  imports = [
    ./disks.nix
    ./hardware.nix
  ];

  networking.hostName = "minimal";

  foosteros.profiles.lily = true;

  system.stateVersion = "23.11";
}
