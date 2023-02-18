{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/profiles/all-hardware.nix"
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
}
