{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.intelgfx {
  hardware.opengl.extraPackages = with pkgs; [
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
    intel-media-driver
  ];
}
