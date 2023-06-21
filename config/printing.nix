{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.printing {
  services.avahi.enable = true;

  services.printing = {
    enable = true;
    drivers = with pkgs; [ canon-cups-ufr2 ];
  };

  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ sane-airscan ];
  };
}
