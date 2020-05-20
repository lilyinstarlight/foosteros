{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "petty";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "fkmclane";
    repo = pname;
    rev = "v${version}";
    sha256 = "12v21wa1m22kvyy6x9csdajmq36j905hl4pakajjbhpx27cf1m96";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    make PREFIX=$out install
  '';

  meta = with stdenv.lib; {
    description = "TTY session starter";
    homepage = "https://github.com/fkmclane/petty";
    license = licenses.mit;
    platforms = platforms.all;
  };

  passthru.shellPath = "/bin/petty";
}
