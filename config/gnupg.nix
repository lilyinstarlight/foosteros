{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.gnupg {
  programs.gnupg.agent.enable = true;
}
