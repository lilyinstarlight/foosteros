{ lib, fetchFromGitHub, mpdris2 }:

mpdris2.overrideAttrs (attrs: rec {
  version = "unstable-2022-06-18";

  src = fetchFromGitHub {
    owner = "eonpatapon";
    repo = attrs.pname;
    rev = "9c4ef808e9820d38966ff6962c342a542899a691";
    hash = "sha256-u5Dd3vq852jlJqVN3iHihFLWtc+btqM+w7hivBCYSxc=";
  };

  meta = with lib; attrs.meta // {
    # TODO: remove once pyopenssl is fixed on darwin
    platforms = platforms.linux;
  };
})
