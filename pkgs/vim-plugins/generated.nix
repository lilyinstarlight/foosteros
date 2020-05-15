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

  jellybeans-vim = buildVimPluginFrom2Nix {
    pname = "jellybeans-vim";
    version = "2019-06-22";
    src = fetchFromGitHub {
      owner = "nanotech";
      repo = "jellybeans.vim";
      rev = "ef83bf4dc8b3eacffc97bf5c96ab2581b415c9fa";
      sha256 = "1zy3gjz5bna3l5a7k2ddqa0w7x8wbndy2vc9gmqfdsxdbhrgpvaz";
    };
  };

  vim-fish = buildVimPluginFrom2Nix {
    pname = "vim-fish";
    version = "2020-04-13";
    src = fetchFromGitHub {
      owner = "NovaDev94";
      repo = "vim-fish";
      rev = "9e48a9dbb54bf1a8d5b8c00220ec77f802eb113d";
      sha256 = "0zp46cry13728g5lzms3akz6c1jggyx3a1wa9xmdvfykg2lb0ww9";
    };
  };

  vim-interestingwords = buildVimPluginFrom2Nix {
    pname = "vim-interestingwords";
    version = "2019-11-02";
    src = fetchFromGitHub {
      owner = "lfv89";
      repo = "vim-interestingwords";
      rev = "2128a825184ef931eeccb193c8009c77c9681c3a";
      sha256 = "1iai2z4mma9kb3hrkfaf22d1ay15ryyvp065is4psmwzm5176jdf";
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

  vim-magnum = buildVimPluginFrom2Nix {
    pname = "vim-magnum";
    version = "2019-11-12";
    src = fetchFromGitHub {
      owner = "glts";
      repo = "vim-magnum";
      rev = "7a30761b935d72bada5bbe90162a6afdb77c858d";
      sha256 = "1fwjmpj3m4p1izd103sc3647xxcq2xp36islablf1qvxl13m3dkl";
    };
  };

  vim-radical = buildVimPluginFrom2Nix {
    pname = "vim-radical";
    version = "2019-11-23";
    src = fetchFromGitHub {
      owner = "glts";
      repo = "vim-radical";
      rev = "15aaf234ed09978d0cd7ae02e9ecd6cf01f0882e";
      sha256 = "1aj8kqz3wssqxkmg3sf4zj39fqdbg6ywknlfk96y7za3968g0sfr";
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

  vim-zeek = buildVimPluginFrom2Nix {
    pname = "vim-zeek";
    version = "2019-08-26";
    src = fetchFromGitHub {
      owner = "zeek";
      repo = "vim-zeek";
      rev = "7e45b6cd94024330da2d70325ff7a9024aa4a1b3";
      sha256 = "00k08pys7k2rmzs44bki8hzp6vfwa8qlbf2qqzrk5swlqnk8djnz";
    };
  };

});
in lib.fix' (lib.extends overrides packages)
