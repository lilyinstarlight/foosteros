{ lib, teams-for-linux, electron_21, libpulseaudio, pipewire }:

teams-for-linux.overrideAttrs (attrs: {
  postInstall = (attrs.postInstall or "") + ''
    makeWrapper '${electron_21}/bin/electron' "$out/bin/teams-for-linux" \
          --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libpulseaudio pipewire ]} \
          --add-flags "$out/share/teams-for-linux/app.asar" \
          --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"
  '';
})
