{ stdenvNoCC, lib, fetchFromGitHub, makeWrapper, ydotool, wofi, wl-clipboard, pass-wayland-otp }:

stdenvNoCC.mkDerivation rec {
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

    substituteInPlace $out/bin/wofi-pass --replace 'wl-copy "$(_pass_get $field)"' '_pass_get "$field" | wl-copy'

    wrapProgram $out/bin/wofi-pass \
      --prefix PATH : ${ydotool}/bin:${wofi}/bin:${wl-clipboard}/bin:${pass-wayland-otp}/bin
  '';

  meta = with lib; {
    description = "Wayland native interface for pass";
    homepage = "https://github.com/AluminumTank/wofi-pass";
    license = licenses.gpl2Only;
  };
}
