{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.steam {
  programs.steam = {
    enable = true;
    extest.enable = true;
  };
}
