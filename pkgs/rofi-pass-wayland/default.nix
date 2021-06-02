{ lib, rofi-pass, rofi-wayland, pass-wayland, coreutils, util-linux, gnugrep, libnotify, pwgen, findutils, gawk, gnused, wl-clipboard, ydotool }:

rofi-pass.overrideAttrs (attrs: rec {
  fixupPhase = ''
    substituteInPlace $out/bin/rofi-pass \
      --replace 'xclip --selection clipboard -o' 'wl-paste' \
      --replace 'xclip -selection clipboard -o' 'wl-paste' \
      --replace 'xclip --selection clipboard' 'wl-copy' \
      --replace 'xclip -selection clipboard' 'wl-copy' \
      --replace 'xclip -o' 'wl-paste -p' \
      --replace 'xclip' 'wl-copy -p' \
      --replace 'xdotool key' 'ydotool key' \
      --replace 'xdotool type' 'ydotool type' \
      --replace '--delay ''${xdotool_delay}' '--next-delay ''${xdotool_delay}' \
      --replace '--clearmodifiers --file -' '--file -'
  '' + attrs.fixupPhase;

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
    ydotool
  ];
})
