# This file has been generated by ./pkgs/vim-plugins/update.py. Do not edit!
{ lib, buildVimPluginFrom2Nix, fetchFromGitHub, overrides ? (self: super: {}) }:

let
  packages = ( self:
{
  hexmode = buildVimPluginFrom2Nix {
    pname = "hexmode";
    version = "2018-11-01";
    src = fetchFromGitHub {
      owner = "fidian";
      repo = "hexmode";
      rev = "06b7b17578df26d853afe17f38e0e711a8fb094c";
      sha256 = "0gq6pj0c25p4p2k24ic4za3qdw2ai0j1wsgynlz94yc53s97jmhf";
    };
  };

});
in lib.fix' (lib.extends overrides packages)
