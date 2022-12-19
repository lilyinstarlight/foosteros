{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    freecad prusa-slicer
  ];
}
