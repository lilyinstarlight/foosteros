{ lib, fetchFromGitHub, mpdris2 }:

mpdris2.overrideAttrs (attrs: rec {
  version = "unstable-2022-04-29";

  src = fetchFromGitHub {
    owner = "eonpatapon";
    repo = attrs.pname;
    rev = "5e5cdacea6e55544064f8b10e0b49bbe2aa044d9";
    hash = "sha256-tcqvKPiOGPCTAW7NSom/oWn+vBuvAln0xeV5PaUihxI=";
  };
})
