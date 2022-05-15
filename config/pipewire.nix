{ config, lib, pkgs, ... }:

{
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # TODO: remove after nixpkgs PR #173160 is merged
  systemd.user.services.pipewire-pulse.path = [ pkgs.pulseaudio ];
}
