{ stdenvNoCC, pkgs, python3Packages, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  name = "fpaste";
  version = "0.1b6";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = "paste";
    rev = "v${version}";
    sha256 = "0jfjgawkym0vi4s5v32sxib8anv32xp2bkn1rrx6yx33365xxyzm";
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

  meta = with pkgs.lib; {
    description = "Command line utility for FoosterNET Paste";
    homepage = "https://github.com/lilyinstarlight/paste";
    license = licenses.mit;
  };
}
