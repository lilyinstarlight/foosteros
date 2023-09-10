{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.fonts {
  fonts.packages = with pkgs; [
    noto-fonts-emoji
    aileron
    noto-fonts noto-fonts-cjk-sans
    dejavu_fonts
    freefont_ttf
    gyre-fonts
    liberation_ttf
    roboto comfortaa
  ];
}
