{ stdenv, pkgs, fetchFromGitHub, makeWrapper }:

stdenv.mkDerivation rec {
  pname = "wofi-pass";
  version = "0.0.0.9999";

  src = fetchFromGitHub {
    owner = "AluminumTank";
    repo = pname;
    #rev = "v${version}";
    rev = "8305359a9af3b27ed0f3f54cf00092bb80a9c6e2";
    sha256 = "0kp26xa8z8krl4agsqbdsf2w1dhadbdxipd7vjl70a53c18wyc1m";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp wofi-pass $out/bin/wofi-pass

    wrapProgram $out/bin/wofi-pass \
      --prefix PATH : ${pkgs.ydotool}/bin:${pkgs.wofi}/bin:${pkgs.wl-clipboard}/bin:${pkgs.pass}/bin
  '';

  meta = with pkgs.lib; {
    description = "Wayland native interface for pass";
    homepage = "https://github.com/AluminumTank/wofi-pass";
    license = licenses.gpl2Only;
  };
}
