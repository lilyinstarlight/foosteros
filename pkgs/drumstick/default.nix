{ fetchurl, drumstick }:

drumstick.overrideAttrs (attrs: rec {
  version = "2.3.1";

  src = fetchurl {
    url = "mirror://sourceforge/${attrs.pname}/${version}/${attrs.pname}-${version}.tar.bz2";
    sha256 = "1rs248pkgn6d29nkvw9ab6dvi1vsz220jdmz1ddzr29cpyc0adfh";
  };
})
