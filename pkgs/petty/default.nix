{ stdenvNoCC, lib, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "petty";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = pname;
    rev = "v${version}";
    sha256 = "1ga896vgmcxgdh906mv2dv0hwqynip6hqf15isi2wfv4mw23j5g9";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    make PREFIX=$out install
  '';

  meta = with lib; {
    description = "TTY session starter";
    homepage = "https://github.com/lilyinstarlight/petty";
    license = licenses.mit;
  };

  passthru.shellPath = "/bin/petty";
}
