{ fetchurl, drumstick, qtx11extras, vmpk }:

vmpk.overrideAttrs (attrs: rec {
  version = "0.8.3";

  src = fetchurl {
    url = "mirror://sourceforge/${attrs.pname}/${version}/${attrs.pname}-${version}.tar.bz2";
    sha256 = "0wk3jvlfdpd76vks4gdrhrv9m8icqbkimg5g3d5ybck3k01qaab6";
  };

  buildInputs = [ drumstick qtx11extras ];

  postInstall = ''
    # vmpk drumstickLocales looks here:
    ln -s ${drumstick}/share/drumstick $out/share/
  '';
})
