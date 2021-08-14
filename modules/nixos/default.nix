{ config, pkgs, lib ? pkgs.lib, ... }:

lib.map (m: import m { inherit config pkgs lib; }) (import ./module-list.nix)
