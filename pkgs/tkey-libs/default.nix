{ lib
, tkeyStdenv
, fetchFromGitHub
, gitUpdater
}:

tkeyStdenv.mkDerivation rec {
  pname = "tkey-libs";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "tillitis";
    repo = "tkey-libs";
    rev = "v${version}";
    hash = "sha256-K+4Td7crh0gB/ZkizKZ3qFjcP3bsEmM9/3z5xgY1IIw=";
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
