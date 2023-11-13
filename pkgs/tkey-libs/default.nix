{ lib
, tkeyStdenv
, fetchFromGitHub
, gitUpdater
}:

tkeyStdenv.mkDerivation rec {
  pname = "tkey-libs";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "tillitis";
    repo = "tkey-libs";
    rev = "v${version}";
    hash = "sha256-20b27SZWaZQksJ+QTZTI6IA57Kiq+R96FE2DPMZKj3c=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp --parents ./app.lds ./*/*.a ./*/*.h $out

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
    maintainers = with maintainers; [ lilyinstarlight ];
  };
}
