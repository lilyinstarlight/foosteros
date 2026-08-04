{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.miracast {
  services.avahi.enable = true;

  environment.systemPackages = with pkgs; [
    gnome-network-displays
  ];

  networking.firewall.trustedInterfaces = lib.mkIf (!config.services.firewalld.enable) [ "p2p-wl+" ];

  services.firewalld.packages = lib.mkIf config.services.firewalld.enable (with pkgs; [
    gnome-network-displays
  ]);
  # TODO: maybe add switch for firewalld policy mode in firewalld profile?
  environment.etc = lib.mkIf config.services.firewalld.enable {
    "polkit-1/actions/org.fedoraproject.FirewallD1.policy".source = "${config.services.firewalld.package}/share/polkit-1/actions/org.fedoraproject.FirewallD1.desktop.policy.choice";
  };
}
