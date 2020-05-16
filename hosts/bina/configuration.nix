{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../config/default.nix
    ../../config/sway.nix
  ];

  networking.hostName = "bina.fooster.network";

  # networking.wireless.enable = true;
  networking.interfaces.ens33.useDHCP = true;

  # services.printing.enable = true;

  services.xserver = {
    # xkbModel = "apple_laptop";
    # xkbVariant = "mac";
  };

  services.nullmailer = {
    enable = true;
    config = {
      me = config.networking.hostName;
      defaultdomain = "fooster.network";
      allmailfrom = "lily@fooster.network";
      adminaddr = "logs@fooster.network";
    };
    # remotesFile = "";
  };

  # services.tlp.enable = true;

  virtualisation.vmware.guest.enable = true;

  system.stateVersion = "20.09";
}
