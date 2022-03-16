{ lib, fetchFromGitHub, mpdris2 }:

mpdris2.overrideAttrs (attrs: rec {
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "eonpatapon";
    repo = attrs.pname;
    rev = version;
    hash = "sha256-1Y6K3z8afUXeKhZzeiaEF3yqU0Ef7qdAj9vAkRlD2p8=";
  };

  patches = (if lib.hasAttr "patches" attrs then attrs.patches else []) ++ [
    ./mpdris2-mp4-cover-art.patch
    ./mpdris2-mopidy-cover-art.patch
  ];
})
