{ stdenvNoCC, lib, fetchFromGitHub, makeWrapper, iproute2, curl }:

stdenvNoCC.mkDerivation rec {
  pname = "dnsimple-ddns";
  version = "unstable-2020-04-16";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = pname;
    rev = "7ea80486077d0f2436ab6031a17eddcb8259af50";
    hash = "sha256-oMGABa58MijGcVW4UF/kMetC5yVyQv1kmJSai4f8r00=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp ddns $out/bin/ddns

    wrapProgram $out/bin/ddns \
      --prefix PATH : "${lib.makeBinPath [ iproute2 curl ]}"
  '';

  meta = with lib; {
    description = "DNSimple zone updater for dynamic IPs";
    homepage = "https://github.com/lilyinstarlight/dnsimple-ddns";
    license = licenses.mit;
    maintainers = with maintainers; [ lilyinstarlight ];
    platforms = platforms.linux;
    mainProgram = "ddns";
  };
}
