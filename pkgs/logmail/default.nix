{ lib
, stdenvNoCC
, fetchFromGitHub
, makeWrapper
, gnugrep
, gnused
, hostname
, systemd
, sendmailPath ? "/run/wrappers/bin/sendmail"
, unstableGitUpdater
}:

stdenvNoCC.mkDerivation {
  pname = "logmail";
  version = "0-unstable-2024-03-11";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = "logmail";
    rev = "13eaba247f305c52dde0ea3627f44b6671ba4a1f";
    hash = "sha256-iU1qg6qJVAd1vgz1S97O8XSvClfI747QTWLJ6K/2Hq8=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  dontConfigure = true;
  dontBuild = true;

  postPatch = ''
    patchShebangs .

    substituteInPlace logmail \
      --replace 'sendmail' '${sendmailPath}'
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp logmail $out/bin/logmail

    wrapProgram $out/bin/logmail \
      --prefix PATH : ${lib.makeBinPath [ gnugrep gnused hostname systemd ]}
  '';

  passthru.updateScript = unstableGitUpdater {};

  meta = with lib; {
    description = "Log error and failed unit digest emailer";
    homepage = "https://github.com/lilyinstarlight/logmail";
    license = licenses.mit;
    maintainers = with maintainers; [ lilyinstarlight ];
    platforms = platforms.linux;
    mainProgram = "logmail";
  };
}
