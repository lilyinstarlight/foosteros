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

  vim-lilypond-integrator = buildVimPluginFrom2Nix {
    pname = "vim-lilypond-integrator";
    version = "2016-03-26";
    src = fetchFromGitHub {
      owner = "gisraptor";
      repo = "vim-lilypond-integrator";
      rev = "7fc48f2e19092a8c8f8e400e2a9afe8c27c90d17";
      sha256 = "0znj10wrz0ggli2l25fvj05qa7r32hbghx24qp8msbdc4vyl3vjx";
    };
  };

  vim-resolve = buildVimPluginFrom2Nix {
    pname = "vim-resolve";
    version = "2019-01-19";
    src = fetchFromGitHub {
      owner = "fkmclane";
      repo = "vim-resolve";
      rev = "a8eaa0156fd6a8f3b0806be51397005f2df693b1";
      sha256 = "11nddnjz751kdj18h5gp4qsvc4w8zfqfip1rw8lcci837254j7dg";
    };
  };

  vim-sonicpi = buildVimPluginFrom2Nix {
    pname = "vim-sonicpi";
    version = "2020-03-26";
    src = fetchFromGitHub {
      owner = "fkmclane";
      repo = "vim-sonicpi";
      rev = "6365b2587ac65f8a4a82febd0c2cfa00638cc6d2";
      sha256 = "02w8zb1bzmwwy1zfl038dbrjgk331amrh5d1ljwdhqm4hssg2d5w";
    };
  };

  vim-spl = buildVimPluginFrom2Nix {
    pname = "vim-spl";
    version = "2018-10-19";
    src = fetchFromGitHub {
      owner = "fkmclane";
      repo = "vim-spl";
      rev = "f89da952dc4c08b0d830370d40cd53886d402547";
      sha256 = "14na2k3f22sg43b0p83q1wiilma5c3b3jz790m35zxgnh1w70fnh";
    };
  };

});
in lib.fix' (lib.extends overrides packages)
