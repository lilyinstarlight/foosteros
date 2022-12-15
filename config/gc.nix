{ config, lib, pkgs, ... }:

{
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
    dates = "weekly";
    persistent = true;
  };
}
