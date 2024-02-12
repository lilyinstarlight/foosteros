{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.production {
  environment.systemPackages = with pkgs; [
    inkscape gimp-with-plugins krita
    helvum qjackctl qsynth vmpk calf
    ardour lmms
    sonic-pi sonic-pi-tool open-stage-control
    lilypond
    (wrapOBS {
      # TODO: re-add obs-backgroundremoval once NixOS/nixpkgs#258392 is in locked nixpkgs flake
      plugins = with obs-studio-plugins; [ wlrobs obs-gstreamer obs-move-transition /*obs-backgroundremoval*/ ];
    })
  ];
}
