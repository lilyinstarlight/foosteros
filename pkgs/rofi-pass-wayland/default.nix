{ lib
, fetchFromGitHub
, fetchpatch
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
  version = "unstable-2021-04-05";

  src = fetchFromGitHub {
    owner = "carnager";
    repo = "rofi-pass";
    rev = "629ad8d73a72d90f531ab6ebbdf78db710e25f2f";
    hash = "sha256-P0ESwjQEvJXFfoi3rjF/99dUbxiAhq+4HxXTMQapSW4=";
  };

  patches = (attrs.patches or []) ++ [
    (fetchpatch {
      name = "rofi-pass-add-native-wayland-support.patch";
      url = "https://github.com/carnager/rofi-pass/commit/73adaaa9d4fa84a4f4adb8d4a21619f0d6826a38.diff";
      hash = "sha256-nWx4REDM/L6syiGE5HyjgkJQ7l0j/u54dRo5KBMeTfc=";
    })
  ];

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

