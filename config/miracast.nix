{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.miracast {
  services.avahi.enable = true;

  networking.firewall.trustedInterfaces = [ "p2p-wl+" ];

  environment.systemPackages = with pkgs; [
    gnome-network-displays
  ];
}
