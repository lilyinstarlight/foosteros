{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.fonts {
  fonts.packages = with pkgs; [
    aileron
    noto-fonts noto-fonts-cjk-sans noto-fonts-emoji
    dejavu_fonts
    freefont_ttf
    gyre-fonts
    liberation_ttf
    roboto comfortaa
  ];
}
