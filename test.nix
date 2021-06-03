{ pkgs ? import <nixpkgs> { config.packageOverrides = (pkgs: import ./pkgs { inherit pkgs; }); }, ... }:

import ./tests { inherit pkgs; }
