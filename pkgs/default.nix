{ pkgs }:

{
  monofur-nerdfont = pkgs.nerdfonts.override {
    fonts = [ "Monofur" ];
  };

  petty = pkgs.callPackage ./petty/default.nix {};
  pridecat = pkgs.callPackage ./pridecat/default.nix {};
  sonic-pi-tool = pkgs.callPackage ./sonic-pi-tool/default.nix {};
  swaynag-battery = pkgs.callPackage ./swaynag-battery/default.nix {};

  python3Packages = pkgs.python3Packages.override {
    overrides = (self: super: {
      oscpy = pkgs.python3Packages.callPackage ./python-modules/oscpy/default.nix {};
    });
  };

  fooster = pkgs.recurseIntoAttrs {
    fpaste = pkgs.callPackage ./fpaste/default.nix {};
    ftmp = pkgs.callPackage ./ftmp/default.nix {};
    furi = pkgs.callPackage ./furi/default.nix {};
    materia-theme = pkgs.callPackage ./materia-theme/default.nix {};
    neovim = pkgs.callPackage ./neovim/default.nix {};
    vimPlugins = pkgs.callPackage ./vim-plugins/default.nix {};
    backgrounds = pkgs.callPackage ./backgrounds/default.nix {};
  };
}
