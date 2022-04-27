{ lib, fetchFromGitHub, mpdris2 }:

mpdris2.overrideAttrs (attrs: rec {
  version = "unstable-2022-04-26";

  src = fetchFromGitHub {
    owner = "eonpatapon";
    repo = attrs.pname;
    rev = "8bf0ae8fc67eb7ad1b7c7d94191eddfcd10c38a8";
    hash = "sha256-3zO93gU9F9aldyNnfaphtCAZY6WqSgmQ0fin9WkHsII=";
  };

  patches = (if lib.hasAttr "patches" attrs then attrs.patches else []) ++ [
    ./mpdris2-cover-art-detection-loop-fix.patch
    ./mpdris2-mopidy-cover-art.patch
  ];
})
