{ stdenv, python3Packages, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "fpaste";
  version = "0.1b6";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = "paste";
    rev = "v${version}";
    sha256 = "0rrl9ms0hijqpxhnfmm7y7h1z2nn9m14rnflcbmc9z0567zhj8w6";
  };

  pythonPath = with python3Packages; [
    httpx
  ];

  nativeBuildInputs = with python3Packages; [
    wrapPython
  ];

  dontBuild = true;

  installPhase = "install -D util/fpaste $out/bin/fpaste";
  postFixup = "wrapPythonPrograms";

  meta = with stdenv.lib; {
    description = "Command line utility for FoosterPASTE";
    homepage = "https://github.com/lilyinstarlight/paste";
    license = licenses.mit;
  };
}
