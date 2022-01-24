{ stdenvNoCC, lib, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "petty";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-6RU5BK9kOy6ijiU4DM2N1mMOwW5iVwMSbK+z+rZJSL0=";
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
    platforms = platforms.linux;
  };

  passthru.shellPath = "/bin/petty";
}
