{ pkgs, stdenv, lib, fetchFromGitHub, makeWrapper, makeDesktopItem, nodejs, electron_7, python3, ... }:

let
  nodeComposition = import ./node-composition.nix {
    inherit pkgs nodejs;
    inherit (stdenv.hostPlatform) system;
  };

  electron = electron_7;
in

nodeComposition.package.override rec {
  src = fetchFromGitHub {
    owner = "jean-emmanuel";
    repo = "open-stage-control";
    rev = "v1.9.11";
    sha256 = "124y0lkrffggmva052j434xbd8crg3qyd6dp1sccnxab73y2rlvv";
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
    patchShebangs --build "$out/lib/node_modules/open-stage-control/node_modules/"

    # build assets
    npm run build

    # make desktop item
    mkdir -p "$out/share"
    ln -s "${desktopItem}/share/applications" "$out/share/applications"

    # wrap electron and include python-rtmidi
    makeWrapper '${electron}/bin/electron' "$out/bin/open-stage-control" \
      --argv0 "$out/bin/open-stage-control" \
      --add-flags "$out/lib/node_modules/open-stage-control/app" \
      --prefix PYTHONPATH : $PYTHONPATH \
      --prefix PATH : "${lib.makeBinPath [ python3 ]}"
  '';

  desktopItem = makeDesktopItem {
    name = "open-stage-control";
    exec = "open-stage-control";
    icon = "open-stage-control";
    desktopName = "Open Stage Control";
    genericName = "Open Stage Control";
    comment = meta.description;
    categories = "Network;";
    extraEntries = ''
      StartupWMClass=open-stage-control
    '';
  };

  meta = with lib; {
    description = "Libre and modular OSC / MIDI controller";
    homepage = "https://openstagecontrol.ammd.net/";
    license = licenses.gpl3;
  };
}
