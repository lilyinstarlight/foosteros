{ lib, stdenv, fetchurl, makeDesktopItem, copyDesktopItems, makeWrapper, wrapGAppsHook, autoPatchelfHook, libpng, zlib, udev, gtk3, pango, cairo, gdk-pixbuf, glib, libX11, webkitgtk, libglvnd, alsa-lib, libXext, libXcursor, libXinerama, libXi, libXrandr, libXScrnSaver, libXxf86vm, libxkbcommon, wayland, coreutils, gnugrep, gnused }:

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
  version = "1.11.1";

  src = fetchurl {
    url = "https://download.panic.com/playdate_sdk/Linux/PlaydateSDK-${version}.tar.gz";
    hash = "sha256-CwM0Cnm3mGbFQELUyhgaaL9RgtHXjC4KJ/JJ9Bnb4jk=";
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
    cat >$out/libexec/PlaydateSimulator <<EOF
    #!/bin/sh
    echo "Linking SDK and copying virtual disk into \$HOME/.Playdate Simluator/sdk..."
    ${coreutils}/bin/mkdir -p "\$HOME/.Playdate Simulator/sdk"
    for dir in $out/sdk/*; do
        if [ "\$(basename "\$dir")" != "Disk" ]; then
            [ ! -e "\$HOME/.Playdate Simulator/sdk/\$(basename "\$dir")" -o -L "\$HOME/.Playdate Simulator/sdk/\$(basename "\$dir")" ] && ${coreutils}/bin/ln -sTf "\$dir" "\$HOME/.Playdate Simulator/sdk/\$(basename "\$dir")"
        else
            ${coreutils}/bin/cp -rT --no-preserve=mode,ownership "\$dir" "\$HOME/.Playdate Simulator/sdk/\$(basename "\$dir")"
        fi
    done

    echo "Setting SDK path to \$HOME/.Playdate Simluator/sdk..."
    if ${gnugrep}/bin/grep -qs "^SDKDirectory=" "\$HOME/.Playdate Simulator/Playdate Simulator.ini"; then
        ${gnused}/bin/sed -i -e "s#^SDKDirectory=.*\\\$#SDKDirectory=\$HOME/.Playdate Simulator/sdk#" "\$HOME/.Playdate Simulator/Playdate Simulator.ini"
    else
        echo >"\$HOME/.Playdate Simulator/Playdate Simulator.ini"
        ${gnused}/bin/sed -i -e "1iSDKDirectory=\$HOME/.Playdate Simulator/sdk\n[LastUsed]\nPDXDirectory=\$HOME/.Playdate Simulator/sdk/Disk/System/Launcher.pdx/" "\$HOME/.Playdate Simulator/Playdate Simulator.ini"
    fi

    exec $out/sdk/bin/PlaydateSimulator "\$@"
    EOF
    chmod +x $out/libexec/PlaydateSimulator

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
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ lilyinstarlight ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "PlaydateSimulator";
  };
}
