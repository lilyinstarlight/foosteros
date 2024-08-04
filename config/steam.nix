{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.steam {
  programs.steam = lib.mkIf pkgs.config.allowUnfree {
    enable = true;
    extest.enable = true;
  };
}
