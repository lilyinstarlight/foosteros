{ lib
, tkeyStdenv
, fetchFromGitHub
, gitUpdater
}:

tkeyStdenv.mkDerivation rec {
  pname = "tkey-libs";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "tillitis";
    repo = "tkey-libs";
    rev = "v${version}";
    hash = "sha256-mrD2PkE0QR7qb2xAzNgWHQ/Nwqe93EMWQGHCbU/t7q4=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp --parents ./app.lds ./*.a ./*/*.h ./*/*/*.h $out

    runHook postInstall
  '';

  # TODO: re-enable when tkey apps support newer libs version
  #passthru.updateScript = gitUpdater {
  #  rev-prefix = "v";
  #};

  meta = with lib; {
    description = "Device libraries for the Tillitis TKey";
    homepage = "https://github.com/tillitis/tkey-libs";
    license = licenses.gpl2Only;
    platforms = platforms.all;
    maintainers = with maintainers; [ lilyinstarlight ];
  };
}
