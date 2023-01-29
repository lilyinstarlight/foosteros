{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, meson
, ninja
, pkg-config
, scdoc
, wayland-scanner
, wayland
, wayland-protocols
, libxkbcommon
, cairo
, gdk-pixbuf
, pam
, glib
, dbus
, fprintd
, unstableGitUpdater
}:

stdenv.mkDerivation rec {
  pname = "swaylock-fprintd";
  version = "unstable-2023-01-28";

  src = fetchFromGitHub {
    owner = "SL-RU";
    repo = "swaylock-fprintd";
    rev = "b7911c21f280aeec9c6934fb39bf1906307424e4";
    hash = "sha256-XPAOkbrpNZSxlXUNYA8QxvD0aS6ehu5BH8qjd44bU6c=";
  };

  patches = [
    (fetchpatch {
      name = "swaylock-fix-option-parsing.patch";
      url = "https://github.com/swaywm/swaylock/commit/2c4bafc57f278fbd2a564c357da410173be28bc6.patch";
      hash = "sha256-iuuindZ1zu2U+tpai1Pic29tKae+VMC2YQwLaTXwlkY=";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    glib
    meson
    ninja
    pkg-config
    scdoc
    wayland-scanner
  ];

  buildInputs = [
    wayland
    wayland-protocols
    libxkbcommon
    cairo
    gdk-pixbuf
    pam
    dbus
  ];

  mesonFlags = [
    "-Dpam=enabled" "-Dgdk-pixbuf=enabled" "-Dman-pages=enabled"
  ];

  postPatch = ''
    substituteInPlace fingerprint/meson.build --replace \
      '/usr/share/dbus-1/interfaces/net.reactivated.Fprint' \
      '${fprintd}/share/dbus-1/interfaces/net.reactivated.Fprint'
  '';

  passthru.updateScript = unstableGitUpdater {};

  meta = with lib; {
    description = "Screen locker for Wayland with fprintd support";
    longDescription = ''
      swaylock-fprintd is a screen locking utility for Wayland
      compositors that supports fprintd login.
    '';
    inherit (src.meta) homepage;
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ lilyinstarlight ];
  };
}
