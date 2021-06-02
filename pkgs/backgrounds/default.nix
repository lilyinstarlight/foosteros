{ stdenvNoCC, lib, fetchzip, sway, jq, nitrogen }:

stdenvNoCC.mkDerivation rec {
  pname = "backgrounds";
  version = "20210525";

  src = fetchzip {
    url = "https://file.lily.flowers/foosteros/backgrounds/20210525.zip";
    stripRoot = false;
    sha256 = "08206p4d2dvmaxlf92zhgycvqqhl1rddvgs07vh44dfjq3c2x4jj";
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
      ${sway}/bin/swaymsg output '*' background "\$(find "\$backgrounds"/"\$(${sway}/bin/swaymsg -t get_outputs | ${jq}/bin/jq '.[0].current_mode.height')" -type f | shuf -n1)" fill
    else
      ${nitrogen}/bin/nitrogen --set-zoom-fill --random "\$backgrounds"
    fi
    EOF
    chmod +x "$out/bin/setbg"
  '';

  meta = with lib; {
    description = "FoosterOS/2 backgrounds";
    homepage = "https://github.com/lilyinstarlight/foosteros";
  };
}
