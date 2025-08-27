{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.production {
  environment.systemPackages = with pkgs; [
    inkscape (gimp-with-plugins.override { plugins = with gimpPlugins; [ lqrPlugin gmic ]; }) krita
    helvum qjackctl qsynth vmpk calf
    # TODO: re-add lmms once NixOS/nixpkgs#437077 is fixed
    #ardour lmms
    ardour
    # TODO: re-add open-stage-control once NixOS/nixpkgs#408849 is fixed and sonic-pi-tool once it works with newer sonic-pi
    #sonic-pi sonic-pi-tool open-stage-control
    sonic-pi
    lilypond
    godot_4
    (wrapOBS {
      plugins = with obs-studio-plugins; [ wlrobs obs-gstreamer obs-move-transition obs-backgroundremoval ];
    })
  ];
}
