{ stdenvNoCC, lib, wrapPython, fetchFromGitHub, httpx }:

stdenvNoCC.mkDerivation rec {
  pname = "ftmp";
  version = "0.1b4";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = "tmp";
    rev = "v${version}";
    sha256 = "10q5lr5zhd81298sv8h32fvwxx3cigaf1kj1md4i6ppx19n61mzl";
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
