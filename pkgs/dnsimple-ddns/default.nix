{ stdenvNoCC, lib, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "dnsimple-ddns";
  version = "unstable-2020-04-16";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = pname;
    rev = "7ea80486077d0f2436ab6031a17eddcb8259af50";
    sha256 = "sha256-oMGABa58MijGcVW4UF/kMetC5yVyQv1kmJSai4f8r00=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp ddns $out/bin/ddns
  '';

  meta = with lib; {
    description = "DNSimple zone updater for dynamic IPs";
    homepage = "https://github.com/lilyinstarlight/dnsimple-ddns";
    license = licenses.mit;
  };
}
