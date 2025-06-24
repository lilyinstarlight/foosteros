{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.production {
  environment.systemPackages = with pkgs; [
    inkscape (gimp-with-plugins.override { plugins = with gimpPlugins; [ lqrPlugin gmic ]; }) krita
    helvum qjackctl qsynth vmpk calf
    # TODO: re-add lmms once NixOS/nixpkgs#418925 is merged
    #ardour lmms
    ardour
    sonic-pi sonic-pi-tool open-stage-control
    lilypond
    godot_4
    (wrapOBS {
      plugins = with obs-studio-plugins; [ wlrobs obs-gstreamer obs-move-transition obs-backgroundremoval ];
    })
  ];
}
