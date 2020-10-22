{ stdenv, python3Packages, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "furi";
  version = "0.1b4";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = "uri";
    rev = "v${version}";
    sha256 = "0np4l58yjsq64mlcmwd6zdm60vnfqwwlxhaq9z0k7hhl9cd5cjr7";
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
