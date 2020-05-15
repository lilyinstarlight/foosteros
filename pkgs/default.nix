{ pkgs }:

{
  fooster = pkgs.recurseIntoAttrs {
    neovim = pkgs.callPackage ./neovim/default.nix { };
  };
}
