{ stdenvNoCC, lib, wrapPython, fetchFromGitHub, httpx, runCommand, gitUpdater }:

stdenvNoCC.mkDerivation rec {
  pname = "furi";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = "uri";
    rev = "v${version}";
    hash = "sha256-WrnbNatAcNYzAmHqzS09h2b3nXmhLX4eHlMx5V4hQm8=";
  };

  strictDeps = true;

  pythonPath = [ httpx ];

  nativeBuildInputs = [ wrapPython ];

  dontBuild = true;
  doInstallCheck = true;

  installPhase = "install -D util/furi $out/bin/furi";

  postFixup = "wrapPythonPrograms";

  installCheckPhase = "$out/bin/furi --help";

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = with lib; {
    description = "Command line utility for FoosterNET Redirect";
    homepage = "https://github.com/lilyinstarlight/uri";
    license = licenses.mit;
    maintainers = with maintainers; [ lilyinstarlight ];
  };
}
