{ lib
, tkeyStdenv
, fetchFromGitHub
, gitUpdater
}:

tkeyStdenv.mkDerivation rec {
  pname = "tkey-libs";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "tillitis";
    repo = "tkey-libs";
    rev = "v${version}";
    hash = "sha256-6V8r67MxLyAUR4mnqvLrPky1Q9KlSbc5t/76yKIJgyo=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp --parents ./app.lds ./*.a ./*/*.h ./*/*/*.h $out

    runHook postInstall
  '';

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = with lib; {
    description = "Device libraries for the Tillitis TKey";
    homepage = "https://github.com/tillitis/tkey-libs";
    license = licenses.gpl2Only;
    platforms = platforms.all;
    maintainers = with maintainers; [ /*lilyinstarlight*/ ];
  };
}
