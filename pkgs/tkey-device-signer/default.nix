{ lib
, tkeyStdenv
, fetchFromGitHub
, tkey-libs
, gitUpdater
}:

tkeyStdenv.mkDerivation rec {
  pname = "tkey-device-signer";
  version = "0.0.7";

  src = fetchFromGitHub {
    owner = "tillitis";
    repo = "tkey-device-signer";
    rev = "v${version}";
    hash = "sha256-H98GMS9rTAUskEHa9dtsJ6ZBVko5FDC62+ou3A3KgS8=";
  };

  makeFlags = [
    "LIBDIR=${tkey-libs}"
    "signer/app.bin"
  ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -T signer/app.bin $out/app.bin

    runHook postInstall
  '';

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = with lib; {
    description = "Ed25519 signer for the Tillitis TKey";
    homepage = "https://github.com/tillitis/tkey-device-signer";
    license = licenses.gpl2Only;
    platforms = platforms.all;
    maintainers = with maintainers; [ lilyinstarlight ];
  };
}
