{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "petty";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = pname;
    rev = "v${version}";
    sha256 = "1cr17m88w1254fwfw50myppqkpw02q0ihy6lhjjz5kidjkgp06ba";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    make PREFIX=$out install
  '';

  meta = with stdenv.lib; {
    description = "TTY session starter";
    homepage = "https://github.com/lilyinstarlight/petty";
    license = licenses.mit;
  };

  passthru.shellPath = "/bin/petty";
}
