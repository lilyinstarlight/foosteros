{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.secureboot {
  environment.systemPackages = with pkgs; [
    sbctl
  ];

  boot.loader.systemd-boot.enable = false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  preservation.preserveAt = lib.mkIf config.preservation.enable {
    ${config.system.devices.preservedState}.directories = [
      "/etc/secureboot"
    ];
  };
}
