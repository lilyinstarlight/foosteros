{ lib, stdenv, fetchurl, makeDesktopItem, copyDesktopItems, makeWrapper, wrapGAppsHook, autoPatchelfHook, libpng, zlib, udev, gtk3, pango, cairo, gdk-pixbuf, glib, libX11, webkitgtk, libglvnd, alsa-lib, libXext, libXcursor, libXinerama, libXi, libXrandr, libXScrnSaver, libXxf86vm, libxkbcommon, wayland }:

let
  simLibDeps = [
    libglvnd
    alsa-lib
    libXext
    libXcursor
    libXinerama
    libXi
    libXrandr
    libXScrnSaver
    libXxf86vm
    libxkbcommon
    wayland
  ];
in

stdenv.mkDerivation rec {
  pname = "playdate-sdk";
  version = "1.10.0";

  src = fetchurl {
    url = "https://download.panic.com/playdate_sdk/Linux/PlaydateSDK-${version}.tar.gz";
    hash = "sha256-aBk5aVfk2iUj53h1acOzOtQdltFG+v5AupyzFX2LPKQ=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    wrapGAppsHook
    autoPatchelfHook
  ];

  buildInputs = [
    # pdc deps
    libpng
    zlib

    # sim deps
    udev
    gtk3
    pango
    cairo
    gdk-pixbuf
    glib
    libX11
    stdenv.cc.cc.lib
    webkitgtk
  ];

  dontConfigure = true;
  dontBuild = true;
  dontWrapGApps = true;

  installPhase = ''
    # SDK
    mkdir -p $out/sdk
    cp -r * $out/sdk/

    # MIME resources
    for size in 16 32 48 512; do
      mkdir -p $out/share/icons/hicolor/$sizex$size/mimetypes
      ln -s $out/sdk/Resources/file-icon/data-$size.png $out/share/icons/hicolor/$sizex$size/mimetypes/application-x-playdate.png
    done
    mkdir -p $out/share/icons/hicolor/scalable/apps
    ln -s $out/sdk/Resources/date.play.simulator.svg $out/share/icons/hicolor/scalable/apps/date.play.simulator.svg

    mkdir -p $out/share/mime/packages
    ln -s $out/sdk/Resources/playdate-types.xml $out/share/mime/packages/playdate-types.xml

    # Helper scripts
    mkdir -p $out/libexec
    cp ${./PlaydateSimulator.sh} $out/libexec/PlaydateSimulator

    # Executables
    makeWrapper $out/sdk/bin/pdc $out/bin/pdc \
      --argv0 $out/sdk/bin/pdc

    makeWrapper $out/sdk/bin/pdutil $out/bin/pdutil \
      --argv0 $out/sdk/bin/pdutil

    makeWrapper $out/libexec/PlaydateSimulator $out/bin/PlaydateSimulator \
      --argv0 $out/libexec/PlaydateSimulator \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : '${lib.makeLibraryPath simLibDeps}' \
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "date.play.simulator";
      desktopName = "Playdate Simulator";
      exec = "PlaydateSimulator %u";
      icon = "date.play.simulator";
      mimeTypes = [ "application/x-playdate-game" "x-scheme-handler/playdate-simulator" ];
      startupWMClass = "PlaydateSimulator";
      categories = [ "Development" ];
      startupNotify = true;
    })
  ];

  meta = with lib; {
    homepage = "https://play.date/dev/";
    description = "Playdate SDK with Lua and C APIs and simulator";
    license = licenses.unfree;
    maintainers = with maintainers; [ lilyinstarlight ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "PlaydateSimulator";
  };
}
