{ lib
, fetchFromGitHub
, rofi-pass
, rofi-wayland
, pass-wayland
, coreutils
, util-linux
, gnugrep
, libnotify
, pwgen
, findutils
, gawk
, gnused
, wl-clipboard
, wtype
, unstableGitUpdater
}:

rofi-pass.overrideAttrs (attrs: rec {
  version = "unstable-2023-07-07";

  src = fetchFromGitHub {
    owner = "carnager";
    repo = "rofi-pass";
    rev = "e77cbdbe0e885f0b1daba3a0b6bae793cc2b1ba3";
    hash = "sha256-zmNuFE+++tf4pKTXSTc7s8R9rvI+XwgWl8mCEPaaIRM=";
  };

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

  doInstallCheck = true;

  fixupPhase = ''
    patchShebangs $out/bin

    wrapProgram $out/bin/rofi-pass \
      --prefix PATH : "${wrapperPath}" \
      --set ROFI_PASS_BACKEND wtype \
      --set ROFI_PASS_CLIPBOARD_BACKEND wl-clipboard
  '';

  installCheckPhase = "$out/bin/rofi-pass --help";

  passthru.updateScript = unstableGitUpdater {};

  meta = with lib; attrs.meta // {
    inherit (attrs.meta) description;
    maintainers = with maintainers; [ lilyinstarlight ] ++ (attrs.meta.maintainers or []);
    platforms = platforms.linux;
  };
})

