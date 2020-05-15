{ pkgs }:

{
  fooster = pkgs.recurseIntoAttrs {
    neovim = pkgs.callPackage ./neovim/default.nix {};
    vimPlugins = pkgs.callPackage ./vim-plugins/default.nix {};
  };
}
