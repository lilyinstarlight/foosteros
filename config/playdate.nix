{ config, lib, pkgs, ... }:

{
  hardware.playdate.enable = true;

  environment.systemPackages = with pkgs; lib.optionals config.nixpkgs.config.allowUnfree [
    playdate-sdk crank
  ];
}
