{ pkgs, ... }:

rec {
  fooster-backgrounds = pkgs.callPackage ./backgrounds {};
  fooster-materia-theme = pkgs.callPackage ./materia-theme {};
  fpaste = pkgs.callPackage ./fpaste {};
  ftmp = pkgs.callPackage ./ftmp {};
  furi = pkgs.callPackage ./furi {};
  petty = pkgs.callPackage ./petty {};
  pridecat = pkgs.callPackage ./pridecat {};
  sonic-pi = pkgs.libsForQt5.callPackage ./sonic-pi {};
  sonic-pi-tool = pkgs.callPackage ./sonic-pi-tool { inherit python3Packages; };
  swaynag-battery = pkgs.callPackage ./swaynag-battery {};
  wofi-pass = pkgs.callPackage ./wofi-pass {};

  monofur-nerdfont = pkgs.nerdfonts.override {
    fonts = [ "Monofur" ];
  };

  python3 = let
    self = pkgs.python3.override {
      packageOverrides = (self: super: {
        oscpy = super.pkgs.callPackage ./python-modules/oscpy {};
      });
      inherit self;
    };
  in self;
  python3Packages = python3.pkgs;

  vimPlugins = pkgs.vimPlugins.extend (self: super: pkgs.callPackage ./vim-plugins {});
}
