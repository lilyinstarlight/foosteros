{ config, lib, pkgs, ... }:

{
  fonts.fonts = with pkgs; [
    aileron
    noto-fonts noto-fonts-extra noto-fonts-cjk-sans noto-fonts-emoji
    dejavu_fonts
    freefont_ttf
    gyre-fonts
    liberation_ttf
  ];
}
