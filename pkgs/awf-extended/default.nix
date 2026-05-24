{ lib
, stdenv
, fetchFromGitHub
, autoreconfHook
, pkg-config
, wrapGAppsHook3
, gtk2
, gtk3
, gtk4
, libnotify
, qt6
, qt5
, gitUpdater
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "awf-extended";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "luigifab";
    repo = "awf-extended";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-wTjMnNQXR8Xe8sR5SBJjnjDFmMym6QfcuunAt2ZKDV8=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -t $out/bin \
      ${finalAttrs.passthru.gtk}/bin/* \
      ${finalAttrs.passthru.qt6}/bin/* \
      ${finalAttrs.passthru.qt5}/bin/*

    runHook postInstall
  '';

  passthru = {
    gtk = stdenv.mkDerivation {
      pname = finalAttrs.pname + "-gtk";
      inherit (finalAttrs) version;

      inherit (finalAttrs) src;

      nativeBuildInputs = [ autoreconfHook pkg-config wrapGAppsHook3 ];
      buildInputs = [ gtk2 gtk3 gtk4 libnotify ];

      postPatch = ''
        substituteInPlace src/Makefile.am \
          --replace '/usr/include/gtk-4.0/unix-print' '${lib.getDev gtk4}/include/gtk-4.0/unix-print' \
          --replace '/usr/include/gtk-3.0/unix-print' '${lib.getDev gtk3}/include/gtk-3.0/unix-print' \
          --replace '/usr/include/gtk-unix-print-2.0' '${lib.getDev gtk2}/include/gtk-unix-print-2.0'

        touch NEWS AUTHORS README ChangeLog
        mv LICENSE COPYING
      '';

      inherit (finalAttrs) meta;
    };

    qt6 = finalAttrs.passthru.gtk.overrideAttrs {
      pname = finalAttrs.pname + "-qt6";

      nativeBuildInputs = [ autoreconfHook pkg-config qt6.wrapQtAppsHook ];
      buildInputs = [ qt6.qtbase ];

      configureFlags = [
        "--enable-only-qt6"
      ];
    };

    qt5 = finalAttrs.passthru.gtk.overrideAttrs {
      pname = finalAttrs.pname + "-qt5";

      nativeBuildInputs = [ autoreconfHook pkg-config qt5.wrapQtAppsHook ];
      buildInputs = [ qt5.qtbase ];

      configureFlags = [
        "--enable-only-qt5"
      ];
    };

    updateScript = gitUpdater {
      rev-prefix = "v";
    };
  };

  meta = with lib; {
    description = "A Widget Factory (extended)";
    longDescription = ''
      A widget factory (extended) is a theme preview application for gtk2,
      gtk3, and gtk4. It displays the various widget types provided by
      gtk2/3/4 in a single window allowing to see the visual effect of the
      applied theme.
    '';
    homepage = "https://github.com/luigifab/awf-extended";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
    maintainers = with maintainers; [ /*lilyinstarlight*/ ];
    mainProgram = "awf-gtk4";
  };
})
