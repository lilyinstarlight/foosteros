{ lib
, stdenv
, rofi
, fetchFromGitHub
, meson
, ninja
, pkg-config
, bison
, check
, flex
, librsvg
, libstartup_notification
, libxkbcommon
, pango
, wayland
, wayland-protocols
, xcbutilwm
, xcbutilxrm
, xcb-util-cursor
, theme ? null, plugins ? [], symlink-dmenu ? false
}:

rofi.override {
  rofi-unwrapped = stdenv.mkDerivation rec {
    pname = "rofi-wayland";
    version = "1.7.0";

    src = fetchFromGitHub {
      owner = "lbonn";
      repo = "rofi";
      #rev = "${version}-wayland";
      rev = "a97ba40bc7aca7e375c500d574cac930a0b3473d";
      fetchSubmodules = true;
      sha256 = "sha256-tiGFkqne8akl576T3PVHSxPUngUWes04muHhjJesiOA=";
    };

    nativeBuildInputs = [
      ninja
      meson
      pkg-config
    ];

    buildInputs = [
      bison
      check
      flex
      librsvg
      libstartup_notification
      libxkbcommon
      pango
      wayland
      wayland-protocols
      xcbutilwm
      xcbutilxrm
      xcb-util-cursor
    ];

    mesonFlags = [
      "-Dwayland=enabled"
    ];

    doCheck = true;

    meta = with lib; {
      description = "Window switcher, run dialog and dmenu replacement (built for Wayland)";
      homepage = "https://github.com/lbonn/rofi";
      license = licenses.mit;
      platforms = platforms.linux;
    };
  };

  inherit theme plugins symlink-dmenu;
}
