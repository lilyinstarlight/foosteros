{ lib
, stdenvNoCC
, fetchzip
, sway
, runtimeShell
, findutils
, jq
, gnugrep
, nitrogen
, xrandr
}:

stdenvNoCC.mkDerivation {
  pname = "backgrounds";
  version = "20210525";

  src = fetchzip {
    url = "https://file.lily.flowers/foosteros/backgrounds/20210525.zip";
    stripRoot = false;
    hash = "sha256-UpIu2MDSNULgPkC/3VoOFGK8mX/wi+RoV3U30cg1QCA=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/backgrounds
    cp -r * $out/backgrounds/

    mkdir -p $out/bin
    cat >$out/bin/setbg <<EOF
    #!${runtimeShell}
    if [ -d "\$HOME"/.backgrounds ]; then
      backgrounds="\$HOME"/.backgrounds
    else
      backgrounds=$out/backgrounds
    fi

    if [ -n "\$SWAYSOCK" ]; then
      ${lib.getExe' sway "swaymsg"} output '*' background "\$(${lib.getExe findutils} "\$backgrounds"/"\$(${lib.getExe' sway "swaymsg"} -t get_outputs | ${lib.getExe jq} '.[0].current_mode.height')" -type f | shuf -n1)" fill
    else
      ${lib.getExe nitrogen} --set-zoom-fill --random "\$backgrounds"/"\$(${lib.getExe' xrandr "xrandr"} --screen 0 | ${lib.getExe gnugrep} -o 'current [0-9]\+ x [0-9]\+' | cut -d' ' -f4)"
    fi
    EOF
    chmod +x "$out/bin/setbg"
  '';

  meta = with lib; {
    description = "FoosterOS/2 backgrounds";
    homepage = "https://github.com/lilyinstarlight/foosteros";
    maintainers = with maintainers; [ lilyinstarlight ];
    platforms = platforms.linux;
  };
}
