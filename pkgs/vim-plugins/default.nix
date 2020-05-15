{ callPackage, config, lib, vimUtils, vim }:

let

  inherit (vimUtils.override {inherit vim;}) buildVimPluginFrom2Nix;

  plugins = callPackage ./generated.nix {
    inherit buildVimPluginFrom2Nix overrides;
  };

  overrides = callPackage ./overrides.nix {
    inherit buildVimPluginFrom2Nix;
  };

in

plugins
