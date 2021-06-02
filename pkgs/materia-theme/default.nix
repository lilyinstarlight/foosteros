{ lib, materia-theme, bc, resvg, optipng, gnome }:

materia-theme.overrideAttrs (attrs: rec {
  nativeBuildInputs = attrs.nativeBuildInputs ++ [ bc resvg optipng ];

  dontConfigure = true;

  installPhase = ''
    patchShebangs change_color.sh install.sh parse-sass.sh render-assets.sh scripts/*.sh src/*/render-assets.sh src/*/render-asset.sh
    sed -i install.sh \
      -e "s|if .*which gnome-shell.*;|if true;|" \
      -e "s|CURRENT_GS_VERSION=.*$|CURRENT_GS_VERSION=${lib.versions.majorMinor gnome.gnome-shell.version}|"
    for script in render-assets.sh src/*/render-asset.sh; do
      sed -i "$script" \
        -e "s|\brendersvg\b|resvg|g"
    done
    ./change_color.sh -t $out/share/themes -o Materia-Fooster <(echo -e "MATERIA_COLOR_VARIANT=dark\nSEL_BG=F29BD4\nFG=EEEEEE\nBG=181818\nHDR_BG=2d2d2d\nHDR_FG=EEEEEE\nMATERIA_SURFACE=343434\nMATERIA_VIEW=242424\n")
  '';
})
