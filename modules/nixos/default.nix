{ config, pkgs, lib, ... }:

lib.map (m: import m { inherit config pkgs lib; }) (import ./modules-list.nix)
