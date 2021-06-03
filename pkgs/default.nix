{ pkgs, ... }:

with pkgs;

rec {
  fooster-backgrounds = callPackage ./backgrounds {};
  fooster-materia-theme = callPackage ./materia-theme {};
  fpaste = python3Packages.callPackage ./fpaste {};
  ftmp = python3Packages.callPackage ./ftmp {};
  furi = python3Packages.callPackage ./furi {};
  helvum = callPackage ./helvum {};
  petty = callPackage ./petty {};
  pridecat = callPackage ./pridecat {};
  rofi-pass-wayland = callPackage ./rofi-pass-wayland {};
  rofi-wayland = callPackage ./rofi-wayland {};
  sonic-pi = libsForQt5.callPackage ./sonic-pi {};
  sonic-pi-tool = python3Packages.callPackage ./sonic-pi-tool {};
  swaynag-battery = callPackage ./swaynag-battery {};

  monofur-nerdfont = nerdfonts.override {
    fonts = [ "Monofur" ];
  };

  pass-wayland-otp = pass-wayland.withExtensions (ext: [ ext.pass-otp ]);

  python3 = let
    self = pkgs.python3.override {
      packageOverrides = (self: super: {
        oscpy = super.pkgs.callPackage ./python-modules/oscpy {};
      });
      inherit self;
    };
  in self;
  python3Packages = python3.pkgs;

  vimPlugins = pkgs.vimPlugins.extend (self: super: callPackage ./vim-plugins {});
}
