{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.gc {
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
    dates = "weekly";
    persistent = true;
  };
}
