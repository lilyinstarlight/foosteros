{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.playdate {
  hardware.playdate.enable = true;

  environment.systemPackages = with pkgs; lib.optionals pkgs.config.allowUnfree [
    # TODO: re-add once playdate-sdk no longer depends on libsoup-2.4
    #playdate-sdk crank
  ];
}
