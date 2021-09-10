{ config, lib, pkgs, ... }:

{
  fonts.fonts = with pkgs; [
    aileron
    noto-fonts noto-fonts-extra noto-fonts-cjk noto-fonts-emoji
    dejavu_fonts
    freefont_ttf
    gyre-fonts
    liberation_ttf
  ];
}
