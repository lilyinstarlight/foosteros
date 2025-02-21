{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.printing {
  services.avahi.enable = true;

  services.printing = {
    enable = true;
  };

  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ sane-airscan ];
  };
}
