# This file has been generated by ./pkgs/vim-plugins/update.py. Do not edit!
{ lib, buildVimPluginFrom2Nix, fetchFromGitHub }:

final: prev:
{
  hexmode = buildVimPluginFrom2Nix {
    pname = "hexmode";
    version = "2021-08-16";
    src = fetchFromGitHub {
      owner = "fidian";
      repo = "hexmode";
      rev = "72190318f03a999de357984df72714114e52f6af";
      sha256 = "0wf0l47amkkmp6fnyzxyyg6ll873nmrkj19kd9kf1ib62chcrwzn";
    };
    meta.homepage = "https://github.com/fidian/hexmode/";
  };

  vim-fish = buildVimPluginFrom2Nix {
    pname = "vim-fish";
    version = "2021-05-21";
    src = fetchFromGitHub {
      owner = "inkch";
      repo = "vim-fish";
      rev = "9e2472a8f3f3953f23343b3e053d80ad0ce6a25f";
      sha256 = "1bz32wfq3402yflj6hfk4jww1ykiki01g191vdji14vyg0dpl91w";
    };
    meta.homepage = "https://github.com/inkch/vim-fish/";
  };

  vim-interestingwords = buildVimPluginFrom2Nix {
    pname = "vim-interestingwords";
    version = "2020-10-29";
    src = fetchFromGitHub {
      owner = "lfv89";
      repo = "vim-interestingwords";
      rev = "e59f97aca15c6180e6f3aceaf4f7b50ca04326ed";
      sha256 = "1pf7vhdvi200lkkz694x0afxlpjl3dcn30jhjgyz0kgby4q9gywc";
    };
    meta.homepage = "https://github.com/lfv89/vim-interestingwords/";
  };

  vim-jdaddy = buildVimPluginFrom2Nix {
    pname = "vim-jdaddy";
    version = "2019-11-13";
    src = fetchFromGitHub {
      owner = "tpope";
      repo = "vim-jdaddy";
      rev = "5cffddb8e644d3a3d0c0ee6a7abf5b713e3c4f97";
      sha256 = "1vzay1f9x3m971ivnd9lfiwmyli8gblzgnw21cs6y20d99xgn670";
    };
    meta.homepage = "https://github.com/tpope/vim-jdaddy/";
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
    meta.homepage = "https://github.com/gisraptor/vim-lilypond-integrator/";
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
    meta.homepage = "https://github.com/glts/vim-magnum/";
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
    meta.homepage = "https://github.com/glts/vim-radical/";
  };

  vim-resolve = buildVimPluginFrom2Nix {
    pname = "vim-resolve";
    version = "2019-01-19";
    src = fetchFromGitHub {
      owner = "lilyinstarlight";
      repo = "vim-resolve";
      rev = "a8eaa0156fd6a8f3b0806be51397005f2df693b1";
      sha256 = "11nddnjz751kdj18h5gp4qsvc4w8zfqfip1rw8lcci837254j7dg";
    };
    meta.homepage = "https://github.com/lilyinstarlight/vim-resolve/";
  };

  vim-sonic-pi = buildVimPluginFrom2Nix {
    pname = "vim-sonic-pi";
    version = "2021-06-28";
    src = fetchFromGitHub {
      owner = "lilyinstarlight";
      repo = "vim-sonic-pi";
      rev = "02e947d377b757c541750ee2101022b460053cb2";
      sha256 = "14bvv8fr48dbl3g5ybdsgmmp7d4ikxcb5gnf5mcgyf2lr4jd2pjb";
    };
    meta.homepage = "https://github.com/lilyinstarlight/vim-sonic-pi/";
  };

  vim-spl = buildVimPluginFrom2Nix {
    pname = "vim-spl";
    version = "2018-10-19";
    src = fetchFromGitHub {
      owner = "lilyinstarlight";
      repo = "vim-spl";
      rev = "f89da952dc4c08b0d830370d40cd53886d402547";
      sha256 = "14na2k3f22sg43b0p83q1wiilma5c3b3jz790m35zxgnh1w70fnh";
    };
    meta.homepage = "https://github.com/lilyinstarlight/vim-spl/";
  };

  vim-zeek = buildVimPluginFrom2Nix {
    pname = "vim-zeek";
    version = "2021-02-23";
    src = fetchFromGitHub {
      owner = "zeek";
      repo = "vim-zeek";
      rev = "bc1024fd470e719c21753eee2034e1eba48642f9";
      sha256 = "0120zr2bdbdk6hbfph9zf30fch3fk0crljv5mk1y0dd1l62synz7";
    };
    meta.homepage = "https://github.com/zeek/vim-zeek/";
  };

  vimwiki-dev = buildVimPluginFrom2Nix {
    pname = "vimwiki-dev";
    version = "2021-12-19";
    src = fetchFromGitHub {
      owner = "vimwiki";
      repo = "vimwiki";
      rev = "4d7a4da2e8e2fff34126e32d8818ba93c66a8a75";
      sha256 = "1xjsyrll5qpmhkky8xrg1d7xhxpk6lyl061szz996kf63k6rz2hv";
    };
    meta.homepage = "https://github.com/vimwiki/vimwiki/";
  };

}
