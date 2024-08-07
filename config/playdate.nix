{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.playdate {
  hardware.playdate.enable = true;

  environment.systemPackages = with pkgs; lib.optionals pkgs.config.allowUnfree [
    playdate-sdk crank
  ];
}
