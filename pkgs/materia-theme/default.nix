{ lib, materia-theme, bc, resvg, optipng, gnused, gtk4, gnome, util-linux, runCommand }:

let fooster-materia-theme =
materia-theme.overrideAttrs (attrs: rec {
  nativeBuildInputs = attrs.nativeBuildInputs ++ [ bc resvg optipng gnused gtk4 gnome.gnome-shell util-linux ];

  propagatedUserEnvPkgs = attrs.propagatedUserEnvPkgs ++ [
    gnome.gnome-themes-extra  # apparently needed for gtk2 style (at least as used by QGtkStyle)
  ];

  dontConfigure = true;

  installPhase = ''
    # fix shebangs
    patchShebangs change_color.sh install.sh parse-sass.sh render-assets.sh scripts/*.sh src/*/render-assets.sh src/*/render-asset.sh

    # fix resvg command name
    for script in render-assets.sh src/*/render-asset.sh; do
      sed -i "$script" \
        -e "s|\brendersvg\b|resvg|g"
    done

    # remove nonexistent asset references for building
    sed -i src/gtk-2.0/assets.txt \
      -e '/^handle-horz-/d' \
      -e '/^handle-vert-/d'

    # make new color scheme
    ./change_color.sh -i false -t $out/share/themes -o Materia-Fooster <(echo -e "MATERIA_COLOR_VARIANT=dark\nSEL_BG=F29BD4\nFG=EEEEEE\nBG=181818\nHDR_BG=2d2d2d\nHDR_FG=EEEEEE\nMATERIA_SURFACE=343434\nMATERIA_VIEW=242424\n")
  '';

  passthru.tests = {
    # test to make sure Materia-Fooster theme was built
    fooster-index-existence = runCommand "${fooster-materia-theme.name}-fooster-index-existence" {} ''
      test -f ${fooster-materia-theme}/share/themes/Materia-Fooster/index.theme >$out
    '';
  };

  meta = with lib; attrs.meta // {
    maintainers = with maintainers; [ lilyinstarlight ] ++ attrs.maintainers;
    platforms = platforms.linux;
  };
})
; in fooster-materia-theme
