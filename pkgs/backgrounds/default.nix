{ stdenvNoCC, lib, fetchzip, sway, findutils, jq, gnugrep, nitrogen, xrandr }:

stdenvNoCC.mkDerivation rec {
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
    #!/bin/sh
    if [ -d "\$HOME"/.backgrounds ]; then
      backgrounds="\$HOME"/.backgrounds
    else
      backgrounds=$out/backgrounds
    fi

    if [ -n "\$SWAYSOCK" ]; then
      ${sway}/bin/swaymsg output '*' background "\$(${findutils}/bin/find "\$backgrounds"/"\$(${sway}/bin/swaymsg -t get_outputs | ${jq}/bin/jq '.[0].current_mode.height')" -type f | shuf -n1)" fill
    else
      ${nitrogen}/bin/nitrogen --set-zoom-fill --random "\$backgrounds"/"\$(${xrandr}/bin/xrandr --screen 0 | ${gnugrep}/bin/grep -o 'current [0-9]\+ x [0-9]\+' | cut -d' ' -f4)"
    fi
    EOF
    chmod +x "$out/bin/setbg"
  '';

  meta = with lib; {
    description = "FoosterOS/2 backgrounds";
    homepage = "https://github.com/lilyinstarlight/foosteros";
    platforms = platforms.linux;
  };
}
