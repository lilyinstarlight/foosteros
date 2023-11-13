{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.tkey {
  hardware.tkey.enable = true;

  environment.systemPackages = with pkgs; [
    tkey-ssh-agent
  ];
}
