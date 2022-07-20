{ stdenvNoCC, lib, fetchFromGitHub, makeWrapper, hostname, sendmailPath ? "/run/wrappers/bin/sendmail" }:

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

  patchPhase = ''
    substituteInPlace logmail \
      --replace 'sendmail' '${sendmailPath}'
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp logmail $out/bin/logmail

    wrapProgram $out/bin/logmail \
      --prefix PATH : "${lib.makeBinPath [ hostname ]}"
  '';

  meta = with lib; {
    description = "Log error and failed unit digest emailer";
    homepage = "https://github.com/lilyinstarlight/logmail";
    license = licenses.mit;
    maintainers = with maintainers; [ lilyinstarlight ];
    platforms = platforms.linux;
    mainProgram = "logmail";
  };
}
