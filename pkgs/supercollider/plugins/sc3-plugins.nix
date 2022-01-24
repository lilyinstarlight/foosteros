{ stdenv, lib, fetchurl, cmake, supercollider, fftw }:

stdenv.mkDerivation rec {
  pname = "sc3-plugins";
  version = "3.11.1";

  src = fetchurl {
    url = "https://github.com/supercollider/sc3-plugins/releases/download/Version-${version}/sc3-plugins-${version}-Source.tar.bz2";
    hash = "sha256-JjUmu7PJ+x3yRibr+Av2gTREng51fPo7Rk+B4y2JvkQ=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    supercollider
    fftw
  ];

  cmakeFlags = [
    "-DSC_PATH=${supercollider}/include/SuperCollider"
    "-DSUPERNOVA=ON"
  ];

  stripDebugList = [ "lib" "share" ];

  meta = with lib; {
    description = "Community plugins for SuperCollider";
    homepage = "https://supercollider.github.io/sc3-plugins/";
    license = licenses.gpl2Plus;
    platforms = [ "x86_64-linux" "i686-linux" "aarch64-linux" "armv7l-linux" ];
  };
}
