{ lib
, tkeyStdenv
, fetchFromGitHub
, tkey-libs
, gitUpdater
}:

tkeyStdenv.mkDerivation rec {
  pname = "tkey-device-signer";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "tillitis";
    repo = "tkey-device-signer";
    rev = "v${version}";
    hash = "sha256-TNXfuToxIvtDc35M/SDjRIwF4QmoqE1lZNQLQFO4BpY=";
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
