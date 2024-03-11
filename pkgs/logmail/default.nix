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
  version = "unstable-2021-12-02";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = "logmail";
    rev = "0912b816f72a53b7b52c436d1c7e9505c811787a";
    hash = "sha256-JdBCa1NQuFQL+dOPQC1mWcQlhy7D1TIn3AZPwhudkro=";
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
