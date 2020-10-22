{ stdenv, python3Packages, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "ftmp";
  version = "0.1b4";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = "tmp";
    rev = "v${version}";
    sha256 = "0ym8gpnm3d0xdq62a2fgqrrz1fxqzxhs9vd169qy3wngwms00i1j";
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
    homepage = "https://github.com/lilyinstarlight/tmp";
    license = licenses.mit;
  };
}
