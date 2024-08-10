{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.miracast {
  services.avahi.enable = true;

  networking.firewall.trustedInterfaces = [ "p2p-wl+" ];

  environment.systemPackages = with pkgs; lib.mkMerge [
    # TODO: revert once sway portal has support for RemoteDesktop
    (lib.mkIf (config.programs.sway.enable || config.services.desktopManager.cosmic.enable) [
      (gnome-network-displays.overrideAttrs (old: {
        version = "0.91.0-unstable-2024-01-27";
        src = fetchFromGitLab {
          domain = "gitlab.gnome.org";
          owner = "GNOME";
          repo = "gnome-network-displays";
          rev = "512e9eb6e57fa2c45db983c3d70033514630578c";
          hash = "sha256-AEq+eS0GF2mBBvldnJs/+f4pHCOPfiOeY6xDO0yeoQU=";
        };
        env.NIX_CFLAGS_COMPILE = old.env.NIX_CFLAGS_COMPILE or "" + " -Wno-format-security";
      }))
    ])
    (lib.mkIf (!config.programs.sway.enable && !config.services.desktopManager.cosmic.enable) [
      gnome-network-displays
    ])
  ];
}
