{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.pipewire {
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };
}
