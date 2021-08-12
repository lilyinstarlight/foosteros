{ lib, rofi-pass, rofi-wayland, pass-wayland, coreutils, util-linux, gnugrep, libnotify, pwgen, findutils, gawk, gnused, wl-clipboard, wtype }:

rofi-pass.overrideAttrs (attrs: rec {
  wrapperPath = with lib; makeBinPath [
    coreutils
    findutils
    gawk
    gnugrep
    gnused
    libnotify
    (pass-wayland.withExtensions (ext: [ ext.pass-otp ]))
    pwgen
    rofi-wayland
    util-linux
    wl-clipboard
    wtype
  ];

  fixupPhase = ''
    substituteInPlace $out/bin/rofi-pass \
      --replace 'xclip --selection clipboard -o' 'wl-paste' \
      --replace 'xclip -selection clipboard -o' 'wl-paste' \
      --replace 'xclip --selection clipboard' 'wl-copy' \
      --replace 'xclip -selection clipboard' 'wl-copy' \
      --replace 'xclip -o' 'wl-paste -p' \
      --replace 'xclip' 'wl-copy -p' \
      --replace 'xdotool key' 'wtype -k' \
      --replace 'xdotool type' 'wtype' \
      --replace '--delay ''${xdotool_delay}' "" \
      --replace '--clearmodifiers --file -' '-' \
      --replace 'x_repeat_enabled=' '#x_repeat_enabled=' \
      --replace 'xset r' '#xset r' \
      --replace 'unset x_repeat_enabled' '#unset x_repeat_enabled'

    patchShebangs $out/bin

    wrapProgram $out/bin/rofi-pass \
      --prefix PATH : "${wrapperPath}"
  '';

  meta = with lib; attrs.meta // {
    platforms = platforms.linux;
  };
})
