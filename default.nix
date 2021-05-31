{ pkgs ? import <nixpkgs> {}, ... }:

{
  pkgs = import ./pkgs/default.nix { inherit pkgs; };
}
