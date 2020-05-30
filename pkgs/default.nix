{ pkgs }:

{
  monofur-nerdfont = pkgs.nerdfonts.override {
    fonts = [ "Monofur" ];
  };

  petty = pkgs.callPackage ./petty/default.nix {};

  fooster = pkgs.recurseIntoAttrs {
    fpaste = pkgs.callPackage ./fpaste/default.nix {};
    ftmp = pkgs.callPackage ./ftmp/default.nix {};
    furi = pkgs.callPackage ./furi/default.nix {};
    materia-theme = pkgs.callPackage ./materia-theme/default.nix {};
    neovim = pkgs.callPackage ./neovim/default.nix {};
    vimPlugins = pkgs.callPackage ./vim-plugins/default.nix {};
  };
}
