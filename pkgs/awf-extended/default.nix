{ lib
, stdenv
, fetchFromGitHub
, autoreconfHook
, pkg-config
, wrapGAppsHook
, gtk2
, gtk3
, gtk4
, gitUpdater
}:

stdenv.mkDerivation rec {
  pname = "awf-extended";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "luigifab";
    repo = "awf-extended";
    rev = "v${version}";
    sha256 = "sha256-4HNYexilyx8N28sRJJw2Us/IQCBKo5HX78OZEAgxjz4=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config wrapGAppsHook ];

  buildInputs = [ gtk2 gtk3 gtk4 ];

  postPatch = ''
    substituteInPlace src/Makefile.am \
      --replace '/usr/include/gtk-4.0/unix-print' '${lib.getDev gtk4}/include/gtk-4.0/unix-print' \
      --replace '/usr/include/gtk-3.0/unix-print' '${lib.getDev gtk3}/include/gtk-3.0/unix-print' \
      --replace '/usr/include/gtk-unix-print-2.0' '${lib.getDev gtk2}/include/gtk-unix-print-2.0'

    touch NEWS AUTHORS README ChangeLog
    mv LICENSE COPYING
  '';

  passthru.updateScript = gitUpdater {};

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
    maintainers = with maintainers; [ lilyinstarlight ];
    mainProgram = "awf-gtk4";
  };
}
