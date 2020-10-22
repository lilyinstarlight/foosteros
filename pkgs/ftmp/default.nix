{ stdenv, python3Packages, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "ftmp";
  version = "0.1b4";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = "tmp";
    rev = "v${version}";
    sha256 = "10q5lr5zhd81298sv8h32fvwxx3cigaf1kj1md4i6ppx19n61mzl";
  };

  pythonPath = with python3Packages; [
    httpx
  ];

  nativeBuildInputs = with python3Packages; [
    wrapPython
  ];

  dontBuild = true;

  installPhase = "install -D util/ftmp $out/bin/ftmp";
  postFixup = "wrapPythonPrograms";

  meta = with stdenv.lib; {
    description = "Command line utility for FoosterNET Temp";
    homepage = "https://github.com/lilyinstarlight/tmp";
    license = licenses.mit;
  };
}
