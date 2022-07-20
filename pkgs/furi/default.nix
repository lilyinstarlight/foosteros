{ stdenvNoCC, lib, wrapPython, fetchFromGitHub, httpx, runCommand }:

let furi =
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

  installPhase = "install -D util/furi $out/bin/furi";

  postFixup = "wrapPythonPrograms";

  passthru.tests = {
    # test to make sure executable runs
    help = runCommand "${furi.name}-help-test" {} ''
      ${furi}/bin/furi --help >$out
    '';
  };

  meta = with lib; {
    description = "Command line utility for FoosterNET Redirect";
    homepage = "https://github.com/lilyinstarlight/uri";
    license = licenses.mit;
    maintainers = with maintainers; [ lilyinstarlight ];
    # TODO: remove once pyopenssl is fixed on darwin
    platforms = platforms.linux;
  };
}
; in furi
