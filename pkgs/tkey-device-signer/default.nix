{ lib
, tkeyStdenv
, fetchFromGitHub
, tkey-libs
#, gitUpdater
, unstableGitUpdater
}:

tkeyStdenv.mkDerivation rec {
  pname = "tkey-device-signer";
  version = "unstable-2023-10-03";

  src = fetchFromGitHub {
    owner = "tillitis";
    repo = "tkey-device-signer";
    #rev = "v${version}";
    rev = "e8c4f0966160b03deeee32413e1eeec2b77c8c6e";
    hash = "sha256-0mSnznXBet7M/91pvw04d6YfcgDvlX1Ntgtr5oCxUpQ=";
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

  #passthru.updateScript = gitUpdater {
  #  rev-prefix = "v";
  #};
  passthru.updateScript = unstableGitUpdater {};

  meta = with lib; {
    description = "Ed25519 signer for the Tillitis TKey";
    homepage = "https://github.com/tillitis/tkey-device-signer";
    license = licenses.gpl2Only;
    platforms = platforms.all;
    maintainers = with maintainers; [ lilyinstarlight ];
  };
}
