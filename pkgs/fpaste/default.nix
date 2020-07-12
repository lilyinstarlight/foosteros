{ stdenv, python3Packages, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "fpaste";
  version = "0.1b5";

  src = fetchFromGitHub {
    owner = "fkmclane";
    repo = "paste";
    rev = "v${version}";
    sha256 = "16dz3b6av2m2lzbgx5s9k3d8x0pz2qb4iwijdk15nm0hjyzz5mlp";
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
    homepage = "https://github.com/fkmclane/paste";
    license = licenses.mit;
  };
}
