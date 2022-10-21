{ lib, fetchFromGitHub, rofi-pass, rofi-wayland, pass-wayland, coreutils, util-linux, gnugrep, libnotify, pwgen, findutils, gawk, gnused, wl-clipboard, wtype, unstableGitUpdater }:

rofi-pass.overrideAttrs (attrs: rec {
  version = "unstable-2021-04-05";

  src = fetchFromGitHub {
    owner = "carnager";
    repo = "rofi-pass";
    rev = "629ad8d73a72d90f531ab6ebbdf78db710e25f2f";
    hash = "sha256-P0ESwjQEvJXFfoi3rjF/99dUbxiAhq+4HxXTMQapSW4=";
  };

  patches = [
    # fix error with latest rofi
    ./rofi-pass-dump-xresources-fix.patch
    # allow using wayland tools
    ./rofi-pass-wayland-tools.patch
  ] ++ (if attrs ? patches then attrs.patches else []);

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

  passthru.updateScript = unstableGitUpdater {
    # TODO: remove when NixOS/nixpkgs#160453 is merged
    url = src.gitRepoUrl;
  };

  meta = with lib; attrs.meta // {
    inherit (attrs.meta) description;
    maintainers = with maintainers; [ lilyinstarlight ] ++ (if attrs.meta ? maintainers then attrs.meta.maintainers else []);
    platforms = platforms.linux;
  };
})

