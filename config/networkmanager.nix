{ config, lib, pkgs, ... }:

{
  networking = {
    useNetworkd = false;

    networkmanager = {
      enable = true;
      wifi.powersave = true;
    };
  };
}
