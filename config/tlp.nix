{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.tlp {
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
    };
  };
}
