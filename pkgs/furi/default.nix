{ stdenv, python3Packages, fetchFromGitHub }:

stdenv.mkDerivation rev {
  name = "furi";
  version = "0.1b2";

  src = fetchFromGitHub {
    owner = "fkmclane";
    repo = "uri";
    rev = "v${version}";
    sha256 = "";
  };

  pythonPath = with python3Packages; [
    requests
  ];

  nativeBuildInputs = with python3Packages; [
    wrapPython
  ];

  dontBuild = true;

  installPhase = "install -D contrib/furi $out/bin/furi";
  postFixup = "wrapPythonPrograms";

  meta = with stdenv.lib; {
    description = "Command line utility for FoosterURI";
    homepage = "https://github.com/fkmclane/uri";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
