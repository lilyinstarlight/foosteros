{ stdenvNoCC, lib, fetchFromGitHub, makeWrapper, hostname, sendmailPath ? "/run/wrappers/bin/sendmail", unstableGitUpdater }:

stdenvNoCC.mkDerivation rec {
  pname = "logmail";
  version = "unstable-2021-12-02";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = pname;
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
      --prefix PATH : "${lib.makeBinPath [ hostname ]}"
  '';

  passthru.updateScript = unstableGitUpdater {
    # TODO: remove when NixOS/nixpkgs#160453 is merged
    url = src.gitRepoUrl;
  };

  meta = with lib; {
    description = "Log error and failed unit digest emailer";
    homepage = "https://github.com/lilyinstarlight/logmail";
    license = licenses.mit;
    maintainers = with maintainers; [ lilyinstarlight ];
    platforms = platforms.linux;
    mainProgram = "logmail";
  };
}
