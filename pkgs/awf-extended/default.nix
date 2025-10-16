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
, gitUpdater
}:

stdenv.mkDerivation rec {
  pname = "awf-extended";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "luigifab";
    repo = "awf-extended";
    rev = "v${version}";
    sha256 = "sha256-UTas/y6Oum9ZzJeta6KglZGlkyp/3EvVOk99roiknCs=";
  };

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

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
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
}
