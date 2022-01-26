{ config, pkgs, lib ? pkgs.lib, fpkgs ? pkgs, ... }:

lib.map (m: import m { inherit config pkgs lib fpkgs; }) (import ./module-list.nix)
