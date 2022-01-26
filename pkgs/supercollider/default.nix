{ lib, stdenv, mkDerivation, fetchurl, callPackage
, cmake, pkg-config, alsa-lib, libjack2, libsndfile
, fftw, curl, gcc, libXt, qtbase, qttools, qtwebengine
, readline, qtwebsockets, useSCEL ? false, emacs
, supercolliderPlugins, writeText, runCommand
, plugins ? []
}:

let
supercollider = mkDerivation rec {
  pname = "supercollider";
  version = "3.12.2";

  src = fetchurl {
    url = "https://github.com/supercollider/supercollider/releases/download/Version-${version}/SuperCollider-${version}-Source.tar.bz2";
    hash = "sha256-1QYorCgSwBK+SVAm4k7HZirr1j+znPmVicFmJdvO3g4=";
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

  passthru.tests = {
    # test to make sure sclang runs and included plugins are successfully found
    sclang-sc3-plugins = let
      supercollider-with-plugins = callPackage ./wrapper.nix {
        inherit supercollider;
        plugins = with supercolliderPlugins; [ sc3-plugins ];
      };
      testsc = writeText "test.sc" ''
        var err = 0;
        try {
        MdaPiano.name.postln;
        } {
        err = 1;
        };
        err.exit;
      '';
    in runCommand "sclang-sc3-plugins-test" {} ''
      timeout 60s env XDG_CONFIG_HOME="$(mktemp -d)" QT_QPA_PLATFORM=minimal ${supercollider-with-plugins}/bin/sclang ${testsc} >$out
    '';
  };

  meta = with lib; {
    description = "Programming language for real time audio synthesis";
    homepage = "https://supercollider.github.io";
    maintainers = with maintainers; [ mrmebelman ];
    license = licenses.gpl3Plus;
    platforms = [ "x86_64-linux" "i686-linux" "aarch64-linux" "armv7l-linux" ];
  };
};

in if plugins == [] then supercollider
else callPackage ./wrapper.nix {
  inherit supercollider plugins;
}
