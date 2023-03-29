{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.cad {
  environment.systemPackages = with pkgs; [
    freecad prusa-slicer
  ];
}
