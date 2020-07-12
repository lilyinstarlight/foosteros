{ stdenv, python3Packages, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "ftmp";
  version = "0.1b3";

  src = fetchFromGitHub {
    owner = "fkmclane";
    repo = "tmp";
    rev = "v${version}";
    sha256 = "0vc0dacjby14v7dxk8ya6l9jr7w64jxh3msrlfql8l6liysa49vq";
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
    description = "Command line utility for FoosterTMP";
    homepage = "https://github.com/fkmclane/tmp";
    license = licenses.mit;
  };
}
