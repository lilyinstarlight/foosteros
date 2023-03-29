{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.nullmailer {
  services.nullmailer = {
    enable = true;
    config = {
      me = config.networking.hostName;
      defaultdomain = "fooster.network";
      allmailfrom = "logs@fooster.network";
      adminaddr = "logs@fooster.network";
    };
  };
}
