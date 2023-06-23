{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.intelgfx {
  hardware.opengl.extraPackages = with pkgs; [
    intel-vaapi-driver
    vaapiVdpau
    libvdpau-va-gl
    intel-media-driver
  ];
}
