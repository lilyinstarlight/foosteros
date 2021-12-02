{ stdenvNoCC, lib, wrapPython, fetchFromGitHub, httpx }:

stdenvNoCC.mkDerivation rec {
  pname = "furi";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = "uri";
    rev = "v${version}";
    sha256 = "sha256-WrnbNatAcNYzAmHqzS09h2b3nXmhLX4eHlMx5V4hQm8=";
  };

  pythonPath = [ httpx ];

  nativeBuildInputs = [ wrapPython ];

  dontBuild = true;

  installPhase = "install -D util/furi $out/bin/furi";
  postFixup = "wrapPythonPrograms";

  meta = with lib; {
    description = "Command line utility for FoosterNET Redirect";
    homepage = "https://github.com/lilyinstarlight/uri";
    license = licenses.mit;
  };
}
