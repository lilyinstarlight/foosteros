{ fetchurl, drumstick, qtx11extras, vmpk }:

vmpk.overrideAttrs (attrs: rec {
  version = "0.8.4";

  src = fetchurl {
    url = "mirror://sourceforge/${attrs.pname}/${version}/${attrs.pname}-${version}.tar.bz2";
    sha256 = "0kh8pns9pla9c47y2nwckjpiihczg6rpg96aignsdsd7vkql69s9";
  };

  buildInputs = [ drumstick qtx11extras ];

  postInstall = ''
    # vmpk drumstickLocales looks here:
    ln -s ${drumstick}/share/drumstick $out/share/
  '';
})
