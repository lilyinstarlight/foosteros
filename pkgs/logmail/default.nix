{ stdenvNoCC, lib, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "logmail";
  version = "unstable-2020-04-16";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = pname;
    rev = "9ba87625f4b0c792d779e0e717ec3b43ff190ea8";
    sha256 = "sha256-9nhlGN2oWX/pq/xDa4732U/IFOLTNNYv8embeBX9UXM=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp logmail $out/bin/logmail
  '';

  meta = with lib; {
    description = "Log error and failed unit digest emailer";
    homepage = "https://github.com/lilyinstarlight/logmail";
    license = licenses.mit;
  };
}
