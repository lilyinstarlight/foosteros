{ config, lib, pkgs, ... }:

{
  networking.firewall.trustedInterfaces = [ "p2p-wl+" ];

  environment.systemPackages = with pkgs; [
    gnome-network-displays
  ];
}
