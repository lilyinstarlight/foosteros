{ config, lib, pkgs }:

let

  inherit (pkgs.vimUtils.override {inherit (pkgs.vim);}) buildVimPluginFrom2Nix;

  plugins = pkgs.callPackage ./generated.nix {
    inherit buildVimPluginFrom2Nix overrides;
  };

  overrides = pkgs.callPackage ./overrides.nix {};

in

plugins
