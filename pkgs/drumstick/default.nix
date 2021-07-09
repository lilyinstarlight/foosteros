{ fetchurl, drumstick }:

drumstick.overrideAttrs (attrs: rec {
  version = "2.3.0";

  src = fetchurl {
    url = "mirror://sourceforge/${attrs.pname}/${version}/${attrs.pname}-${version}.tar.bz2";
    sha256 = "12haksnf91ra5w5dwnlc3rcw4js8wj4hsl6kzyqrx4q4fnpvjahk";
  };
})
