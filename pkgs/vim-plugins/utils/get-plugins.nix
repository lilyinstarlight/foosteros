with import (builtins.getEnv "NIXPKGS_PATH") { };
let
  inherit (vimUtils.override { inherit vim; }) buildVimPlugin;
  inherit (neovimUtils) buildNeovimPlugin;

  generated = callPackage <localpkgs/pkgs/vim-plugins/generated.nix> {
    inherit buildNeovimPlugin buildVimPlugin;
  } { } { };

  hasChecksum =
    value:
    lib.isAttrs value
    && lib.hasAttrByPath [
      "src"
      "outputHash"
    ] value;

  parse = name: value: {
    inherit (value) pname version;
    homePage = value.meta.homepage;
    checksum =
      if hasChecksum value then
        {
          submodules = value.src.fetchSubmodules or false;
          sha256 = value.src.outputHash;
          inherit (value.src) rev;
          tag = value.src.tag or null;
        }
      else
        null;
  };
in
lib.mapAttrs parse generated
