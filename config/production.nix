{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    inkscape gimp-with-plugins krita
    helvum qjackctl qsynth vmpk calf
    ardour lmms
    sonic-pi sonic-pi-tool open-stage-control
    lilypond
    (wrapOBS {
      plugins = with obs-studio-plugins; [ wlrobs obs-gstreamer obs-move-transition ] ++ (lib.optionals config.nixpkgs.config.allowUnfree [ (obs-ndi.override {
        ndi = ndi.overrideAttrs (attrs: rec {
          src = fetchurl {
            name = "${attrs.pname}-${attrs.version}.tar.gz";
            url = "https://downloads.ndi.tv/SDK/NDI_SDK_Linux/Install_NDI_SDK_v5_Linux.tar.gz";
            hash = "sha256-ANC+3Cxyc22CiD/A/WvBpUTnlYx+Rtt58yZjPUThUVM=";
          };

          unpackPhase = ''unpackFile ${src}; echo y | ./${attrs.installerName}.sh; sourceRoot="NDI SDK for Linux";'';
        });
      }) ]);
    })
  ];
}
