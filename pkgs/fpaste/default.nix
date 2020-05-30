{ stdenv, python3Packages, fetchFromGitHub }:

stdenv.mkDerivation rev {
  name = "fpaste";
  version = "0.1b2";

  src = fetchFromGitHub {
    owner = "fkmclane";
    repo = "paste";
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

  installPhase = "install -D contrib/fpaste $out/bin/fpaste";
  postFixup = "wrapPythonPrograms";

  meta = with stdenv.lib; {
    description = "Command line utility for FoosterPASTE";
    homepage = "https://github.com/fkmclane/paste";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
