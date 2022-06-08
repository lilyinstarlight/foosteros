{ pkgs, stdenv, lib, fetchFromGitHub, makeWrapper, makeDesktopItem, copyDesktopItems, nodejs, electron, python3, runCommand, ... }:

let
  nodeComposition = import ./node-composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };
in

let open-stage-control =
nodeComposition.package.override rec {
  pname = "open-stage-control";
  inherit (nodeComposition.args) version;

  src = fetchFromGitHub {
    owner = "jean-emmanuel";
    repo = "open-stage-control";
    rev = "v${version}";
    hash = "sha256-oQwnFWEjczB8WRsWn698oNN1nzG4D+npt+k7Im8wSpQ=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [
    python3.pkgs.python-rtmidi
  ];

  dontNpmInstall = true;

  preRebuild = ''
    # remove electron dependencies from package.json
    mv package.json package.orig.json
    grep -v '"electron"\|"electron-installer-debian"\|"electron-packager"\|"electron-packager-plugin-non-proprietary-codecs-ffmpeg"' package.orig.json >package.json
  '';

  postInstall = ''
    # fix shebangs in node_modules
    patchShebangs --build $out/lib/node_modules/open-stage-control/node_modules/

    # build assets
    npm run build

    # copy icon
    install -Dm644 resources/images/logo.png $out/share/icons/hicolor/256x256/apps/open-stage-control.png
    install -Dm644 resources/images/logo.svg $out/share/icons/hicolor/scalable/apps/open-stage-control.svg

    # wrap electron and include python-rtmidi
    makeWrapper '${electron}/bin/electron' $out/bin/open-stage-control \
      --argv0 $out/bin/open-stage-control \
      --add-flags $out/lib/node_modules/open-stage-control/app \
      --prefix PYTHONPATH : $PYTHONPATH \
      --prefix PATH : ${lib.makeBinPath [ python3 ]}
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "open-stage-control";
      exec = "open-stage-control";
      icon = "open-stage-control";
      desktopName = "Open Stage Control";
      comment = meta.description;
      categories = [ "Network" "Audio" "AudioVideo" "Midi" ];
      startupWMClass = "open-stage-control";
    })
  ];

  passthru.tests = {
    # test to make sure executable runs
    help = runCommand "${open-stage-control.name}-help-test" {} ''
      env XDG_CONFIG_HOME="$(mktemp -d)" ${open-stage-control}/bin/open-stage-control --help >$out
    '';
  };

  meta = with lib; {
    description = "Libre and modular OSC / MIDI controller";
    homepage = "https://openstagecontrol.ammd.net/";
    license = licenses.gpl3;
    maintainers = with maintainers; [ lilyinstarlight ];
    platforms = [ "x86_64-linux" "aarch64-linux" "i686-linux" "armv7l-linux" ];
  };
}
; in open-stage-control
