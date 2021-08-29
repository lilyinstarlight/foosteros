{ stdenv, lib, fetchurl, cmake, supercollider, fftw }:

stdenv.mkDerivation rec {
  pname = "sc3-plugins";
  version = "3.11.1";

  src = fetchurl {
    url = "https://github.com/supercollider/sc3-plugins/releases/download/Version-${version}/sc3-plugins-${version}-Source.tar.bz2";
    sha256 = "0i5yi4ny70ag8qxzlz3m1sg48d41yq5zisr68vr1vyy9nfxjcd96";
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

  meta = with lib; {
    description = "Community plugins for SuperCollider";
    homepage = "https://supercollider.github.io/sc3-plugins/";
    license = licenses.gpl2Plus;
    platforms = [ "i686-linux" "x86_64-linux" ];
  };
}
