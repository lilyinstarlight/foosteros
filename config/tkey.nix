{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.tkey {
  hardware.tkey.enable = true;
  programs.tkey-ssh-agent = {
    enable = true;
    userSuppliedSecret = true;
  };
}
