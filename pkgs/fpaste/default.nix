{ stdenvNoCC, lib, wrapPython, fetchFromGitHub, httpx, runCommand, gitUpdater }:

stdenvNoCC.mkDerivation rec {
  pname = "fpaste";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = "paste";
    rev = "v${version}";
    hash = "sha256-y+qf85V+IpT1NaXMJKiBg8sWH/1DEVbMqmGo0iYQgxE=";
  };

  strictDeps = true;

  pythonPath = [ httpx ];

  nativeBuildInputs = [ wrapPython ];

  dontBuild = true;
  doInstallCheck = true;

  installPhase = "install -D util/fpaste $out/bin/fpaste";

  postFixup = "wrapPythonPrograms";

  installCheckPhase = "$out/bin/fpaste --help";

  passthru.updateScript = gitUpdater {
    # TODO: remove when NixOS/nixpkgs#160453 is merged
    url = src.gitRepoUrl;
    rev-prefix = "v";
  };

  meta = with lib; {
    description = "Command line utility for FoosterNET Paste";
    homepage = "https://github.com/lilyinstarlight/paste";
    license = licenses.mit;
    maintainers = with maintainers; [ lilyinstarlight ];
  };
}
