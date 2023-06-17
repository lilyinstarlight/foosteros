# This file has been generated by ./pkgs/vim-plugins/update.py. Do not edit!
{ lib, buildVimPluginFrom2Nix, buildNeovimPluginFrom2Nix, fetchFromGitHub, fetchgit }:

final: prev:
{
  hexmode = buildVimPluginFrom2Nix {
    pname = "hexmode";
    version = "2023-02-08";
    src = fetchFromGitHub {
      owner = "fidian";
      repo = "hexmode";
      rev = "550cae65fdbd06d61d757dc6fe5a9be5be2e3ef4";
      sha256 = "0ap2iycs71553wagjch2baz90kv59dhc8sddkiza80p50jyc8ab6";
    };
    meta.homepage = "https://github.com/fidian/hexmode/";
  };

  vim-fish = buildVimPluginFrom2Nix {
    pname = "vim-fish";
    version = "2022-03-06";
    src = fetchFromGitHub {
      owner = "inkch";
      repo = "vim-fish";
      rev = "e648eaf250be676eef02b3e2c9e25eabfdb2ed75";
      sha256 = "1zpjg656wgxgq5za06ql1z7ajls58gbcy1chkm83fnh1h2kr6c99";
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
    version = "2022-03-26";
    src = fetchFromGitHub {
      owner = "tpope";
      repo = "vim-jdaddy";
      rev = "23b67752cb869dd9c8f3109173b69aa96a1f3acf";
      sha256 = "1frkyq5zpwkwrrjcf0sscmr6q696vaaxnc0r93mk9psv5zbna4vl";
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
    version = "2022-06-07";
    src = fetchFromGitHub {
      owner = "glts";
      repo = "vim-radical";
      rev = "95ad54adf048dfadf54a49ba1a0c906b689f89dd";
      sha256 = "0frpvcqnblkqjdqfllbxnz7hla29p8ys7vagyncm1ixdzllgfbs6";
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
    version = "2022-08-08";
    src = fetchFromGitHub {
      owner = "lilyinstarlight";
      repo = "vim-sonic-pi";
      rev = "7af4b0b5039cdb6e1721ef5e19f6f6114f2179bd";
      sha256 = "099gy6ij54jaa9ln1z19kigxg8gsx0n2plwf8vm0ay9x933cv5jn";
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
    version = "2023-06-16";
    src = fetchFromGitHub {
      owner = "vimwiki";
      repo = "vimwiki";
      rev = "88620a2be0d47e74639b15c71f7e170bb3b2d432";
      sha256 = "1hw19wkrv98qvynak6ag79dffxafiv574bg52886wglrrimhl1y1";
    };
    meta.homepage = "https://github.com/vimwiki/vimwiki/";
  };


}
