{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.production {
  environment.systemPackages = with pkgs; [
    inkscape (gimp-with-plugins.override { plugins = with gimpPlugins; [ lqrPlugin gmic ]; }) krita
    helvum qjackctl qsynth vmpk calf
    # TODO: re-add lmms once NixOS/nixpkgs#418925 is merged
    #ardour lmms
    ardour
    # TODO: re-add open-stage-control once NixOS/nixpkgs#408849 is fixed
    #sonic-pi sonic-pi-tool open-stage-control
    sonic-pi sonic-pi-tool
    lilypond
    godot_4
    (wrapOBS {
      plugins = with obs-studio-plugins; [ wlrobs obs-gstreamer obs-move-transition obs-backgroundremoval ];
    })
  ];
}
