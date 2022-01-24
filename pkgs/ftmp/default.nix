{ stdenvNoCC, lib, wrapPython, fetchFromGitHub, httpx }:

stdenvNoCC.mkDerivation rec {
  pname = "ftmp";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = "tmp";
    rev = "v${version}";
    hash = "sha256-9X9uhqEutS3HAgyQxV6Gh4scJhX70AROHHpBIpTrUS8=";
  };

  pythonPath = [ httpx ];

  nativeBuildInputs = [ wrapPython ];

  dontBuild = true;

  installPhase = "install -D util/ftmp $out/bin/ftmp";
  postFixup = "wrapPythonPrograms";

  meta = with lib; {
    description = "Command line utility for FoosterNET Temp";
    homepage = "https://github.com/lilyinstarlight/tmp";
    license = licenses.mit;
  };
}
