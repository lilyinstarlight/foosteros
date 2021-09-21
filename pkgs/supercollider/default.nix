{ lib, stdenv, mkDerivation, fetchurl, callPackage
, cmake, pkg-config, alsa-lib, libjack2, libsndfile
, fftw, curl, gcc, libXt, qtbase, qttools, qtwebengine
, readline, qtwebsockets, useSCEL ? false, emacs
, plugins ? []
}:

let
supercollider = mkDerivation rec {
  pname = "supercollider";
  version = "3.12.1";

  src = fetchurl {
    url = "https://github.com/supercollider/supercollider/releases/download/Version-${version}/SuperCollider-${version}-Source.tar.bz2";
    sha256 = "sha256-neYId2hJRAMx4+ZFm+5TzYuUbMRfa9icyqm2UYac/Cs=";
  };

  patches = [
    ./supercollider-3.12.0-env-dirs.patch
  ];

  hardeningDisable = [ "stackprotector" ];

  cmakeFlags = [
    "-DSC_WII=OFF"
    "-DSC_EL=${if useSCEL then "ON" else "OFF"}"
  ];

  nativeBuildInputs = [ cmake pkg-config qttools ];

  buildInputs = [
    gcc libjack2 libsndfile fftw curl libXt qtbase qtwebengine qtwebsockets readline ]
      ++ lib.optional (!stdenv.isDarwin) alsa-lib
      ++ lib.optional useSCEL emacs;

  meta = with lib; {
    description = "Programming language for real time audio synthesis";
    homepage = "https://supercollider.github.io";
    maintainers = with maintainers; [ mrmebelman ];
    license = licenses.gpl3Plus;
    platforms = [ "i686-linux" "x86_64-linux" ];
  };
};

in if plugins == [] then supercollider
else callPackage ./wrapper.nix {
  inherit supercollider plugins;
}
