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
  version = "unstable-2023-01-30";

  src = fetchFromGitHub {
    owner = "SL-RU";
    repo = "swaylock-fprintd";
    rev = "236a6974f5c49787a8ae127670319eacdbb1b40b";
    hash = "sha256-UYidVUn/LRPOQy2bRkYruNGTt9fM8WDiXyiEaJp4Eq4=";
  };

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
