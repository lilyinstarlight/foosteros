{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.printing {
  services.avahi.enable = true;

  services.printing = {
    enable = true;
    drivers = with pkgs; (lib.optionals pkgs.config.allowUnfree [
      canon-cups-ufr2
    ]);
  };

  hardware.sane = {
    enable = true;
    extraBackends = with pkgs; [ sane-airscan ];
  };
}
