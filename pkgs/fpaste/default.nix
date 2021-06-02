{ stdenvNoCC, lib, wrapPython, fetchFromGitHub, httpx }:

stdenvNoCC.mkDerivation rec {
  name = "fpaste";
  version = "0.1b6";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = "paste";
    rev = "v${version}";
    sha256 = "0jfjgawkym0vi4s5v32sxib8anv32xp2bkn1rrx6yx33365xxyzm";
  };

  pythonPath = [ httpx ];

  nativeBuildInputs = [ wrapPython ];

  dontBuild = true;

  installPhase = "install -D util/fpaste $out/bin/fpaste";
  postFixup = "wrapPythonPrograms";

  meta = with lib; {
    description = "Command line utility for FoosterNET Paste";
    homepage = "https://github.com/lilyinstarlight/paste";
    license = licenses.mit;
  };
}
