{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    inputs.envfs.nixosModules.envfs
  ];

  programs.nix-ld.enable = true;

  environment.systemPackages = with inputs.nix-alien.packages.${pkgs.stdenv.hostPlatform.system}; [ nix-alien ];
}
