{ lib
, stdenv
, fetchFromGitHub
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
  version = "0-unstable-2023-11-09";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = "swaylock";
    rev = "ee1f9a1f6740dd65b22063b0e03d446a16733d18";
    hash = "sha256-axNkBgJVo5EIqy0iKQEcQ9fAQAy+PKg7hnndNO4pmyw=";
  };

  strictDeps = true;

  depsBuildBuild = [
    pkg-config
  ];

  nativeBuildInputs = [
    pkg-config
    glib
    meson
    ninja
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
    "-Dpam=enabled" "-Dfingerprint=enabled" "-Dgdk-pixbuf=enabled" "-Dman-pages=enabled"
  ];

  postPatch = ''
    substituteInPlace fingerprint/meson.build --replace \
      '/usr/share/dbus-1/interfaces/net.reactivated.Fprint' \
      '${fprintd}/share/dbus-1/interfaces/net.reactivated.Fprint'
  '';

  passthru.updateScript = unstableGitUpdater {
    branch = "fprintd";
  };

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
    mainProgram = "swaylock";
  };
}
