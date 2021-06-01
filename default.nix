{ pkgs ? import <nixpkgs> {}, ... }:

import ./pkgs/default.nix { inherit pkgs; }
