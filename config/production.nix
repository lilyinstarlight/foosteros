{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.production {
  environment.systemPackages = with pkgs; [
    inkscape gimp-with-plugins krita
    helvum qjackctl qsynth vmpk calf
    ardour lmms
    sonic-pi sonic-pi-tool open-stage-control
    lilypond
    (wrapOBS {
      plugins = with obs-studio-plugins; [ wlrobs obs-gstreamer obs-move-transition obs-backgroundremoval ] ++ (lib.optionals pkgs.config.allowUnfree [ (obs-ndi.override {
        # TODO: remove override when NixOS/nixpkgs#247094 is merged
        ndi = ndi.overrideAttrs (attrs: rec {
          version = "5.6.0";

          src = fetchurl {
            name = "${attrs.pname}-${version}.tar.gz";
            url = "https://downloads.ndi.tv/SDK/NDI_SDK_Linux/Install_NDI_SDK_v5_Linux.tar.gz";
            hash = "sha256-T/S5LyxfQtI0qn0ULi3n6bBFxytGrVFJpFnUjv2SGN4=";
          };

          installPhase = lib.concatStringsSep "\n" (lib.filter (line: !(lib.hasPrefix "mv logos " line)) (lib.splitString "\n" attrs.installPhase));
        });
      }) ]);
    })
  ];
}
