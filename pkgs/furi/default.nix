{ stdenv, python3Packages, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "furi";
  version = "0.1b4";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = "uri";
    rev = "v${version}";
    sha256 = "1a3d60cg8j7c781skbhna26nphn6zwv2rwfc6r6cv3vhspwz1mj5";
  };

  pythonPath = with python3Packages; [
    httpx
  ];

  nativeBuildInputs = with python3Packages; [
    wrapPython
  ];

  dontBuild = true;

  installPhase = "install -D util/furi $out/bin/furi";
  postFixup = "wrapPythonPrograms";

  meta = with stdenv.lib; {
    description = "Command line utility for FoosterNET Redirect";
    homepage = "https://github.com/lilyinstarlight/uri";
    license = licenses.mit;
  };
}
