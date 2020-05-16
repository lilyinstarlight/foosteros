{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    qutebrowser firefox google-chrome
  ];

  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      swaylock swayidle xwayland
      wofi i3status alacritty
      arc-theme bibata-cursors papirus-icon-theme nerdfonts
      slurp grim
    ];
  };
}
