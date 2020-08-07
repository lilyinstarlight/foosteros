{ stdenv, pkgs }:

pkgs.materia-theme.overrideAttrs (attrs: rec {
  version = "20200320";

  src = pkgs.fetchFromGitHub {
    owner = "nana-4";
    repo = "materia-theme";
    rev = "v${version}";
    sha256 = "0g4b7363hzs7z9xghldlz9aakmzzp18hhx32frb6qxy04lna2lwk";
  };

  patches = [ ./inkscape-1.0-fix.patch ];

  nativeBuildInputs = attrs.nativeBuildInputs ++ (with pkgs; [ sassc inkscape optipng ]);

  installPhase = ''
    patchShebangs change_color.sh install.sh parse-sass.sh render-assets.sh scripts/*.sh src/*/render-assets.sh src/*/render-asset.sh
    sed -i install.sh \
      -e "s|if .*which gnome-shell.*;|if true;|" \
      -e "s|CURRENT_GS_VERSION=.*$|CURRENT_GS_VERSION=${stdenv.lib.versions.majorMinor pkgs.gnome3.gnome-shell.version}|"
    ./change_color.sh -t $out/share/themes -o Materia-Fooster <(echo -e "MATERIA_COLOR_VARIANT=dark\nSEL_BG=F29BD4\nFG=EEEEEE\nBG=181818\nHDR_BG=2d2d2d\nHDR_FG=EEEEEE\nMATERIA_SURFACE=343434\nMATERIA_VIEW=242424\n")
    rm $out/share/themes/*/COPYING
  '';
})
