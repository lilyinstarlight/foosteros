{ stdenv, python3Packages, fetchFromGitHub }:

stdenv.mkDerivation rev {
  name = "ftmp";
  version = "0.1b2";

  src = fetchFromGitHub {
    owner = "fkmclane";
    repo = "tmp";
    rev = "v${version}";
    sha256 = "";
  };

  pythonPath = with python3Packages; [
    requests
    requests-toolbelt
  ];

  nativeBuildInputs = with python3Packages; [
    wrapPython
  ];

  dontBuild = true;

  installPhase = "install -D contrib/ftmp $out/bin/ftmp";
  postFixup = "wrapPythonPrograms";

  meta = with stdenv.lib; {
    description = "Command line utility for FoosterTMP";
    homepage = "https://github.com/fkmclane/tmp";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
