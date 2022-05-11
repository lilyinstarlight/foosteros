{ stdenvNoCC, lib, wrapPython, fetchFromGitHub, httpx, runCommand }:

let fpaste =
stdenvNoCC.mkDerivation rec {
  pname = "fpaste";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = "paste";
    rev = "v${version}";
    hash = "sha256-y+qf85V+IpT1NaXMJKiBg8sWH/1DEVbMqmGo0iYQgxE=";
  };

  pythonPath = [ httpx ];

  nativeBuildInputs = [ wrapPython ];

  dontBuild = true;

  installPhase = "install -D util/fpaste $out/bin/fpaste";

  postFixup = "wrapPythonPrograms";

  passthru.tests = {
    # test to make sure executable runs
    help = runCommand "${fpaste.name}-help-test" {} ''
      ${fpaste}/bin/fpaste --help >$out
    '';
  };

  meta = with lib; {
    description = "Command line utility for FoosterNET Paste";
    homepage = "https://github.com/lilyinstarlight/paste";
    license = licenses.mit;
    maintainers = with maintainers; [ lilyinstarlight ];
    # TODO: remove once pyopenssl is fixed on darwin
    platforms = platforms.linux;
  };
}
; in fpaste
