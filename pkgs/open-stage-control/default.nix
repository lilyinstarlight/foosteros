{ pkgs, stdenv, lib, fetchFromGitHub, makeWrapper, makeDesktopItem, nodejs, electron, python3, ... }:

let
  nodeComposition = import ./node-composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };
in

nodeComposition.package.override rec {
  src = fetchFromGitHub {
    owner = "jean-emmanuel";
    repo = "open-stage-control";
    rev = "v1.14.3";
    hash = "sha256-C5TDDduMzIILYmz4quQ+dftAfOvSJnt+T3oMst3se40=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [
    python3.pkgs.python-rtmidi
  ];

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

    # make desktop item
    mkdir -p $out/share
    ln -s "${desktopItem}/share/applications" $out/share/applications

    # wrap electron and include python-rtmidi
    makeWrapper '${electron}/bin/electron' $out/bin/open-stage-control \
      --argv0 $out/bin/open-stage-control \
      --add-flags $out/lib/node_modules/open-stage-control/app \
      --prefix PYTHONPATH : $PYTHONPATH \
      --prefix PATH : ${lib.makeBinPath [ python3 ]}
  '';

  desktopItem = makeDesktopItem {
    name = "open-stage-control";
    exec = "open-stage-control";
    icon = "open-stage-control";
    desktopName = "Open Stage Control";
    comment = meta.description;
    categories = "Network;Audio;AudioVideo;Midi;";
    extraEntries = ''
      StartupWMClass=open-stage-control
    '';
  };

  meta = with lib; {
    description = "Libre and modular OSC / MIDI controller";
    homepage = "https://openstagecontrol.ammd.net/";
    license = licenses.gpl3;
    platforms = [ "x86_64-linux" "aarch64-linux" "i686-linux" "armv7l-linux" ];
  };
}
