{ stdenvNoCC, lib, fetchFromGitHub, makeWrapper, hostname, sendmailPath ? "/run/wrappers/bin/sendmail", unstableGitUpdater }:

stdenvNoCC.mkDerivation rec {
  pname = "logmail";
  version = "unstable-2020-04-16";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = pname;
    rev = "9ba87625f4b0c792d779e0e717ec3b43ff190ea8";
    hash = "sha256-9nhlGN2oWX/pq/xDa4732U/IFOLTNNYv8embeBX9UXM=";
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
