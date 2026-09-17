{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.vps {
  foosteros.profiles = {
    grub = lib.mkDefault true;
    networkd = lib.mkDefault true;
  };

  boot.initrd.services.lvm.enable = true;

  networking.usePredictableInterfaceNames = lib.mkDefault false;
  networking.useDHCP = lib.mkDefault false;
  networking.interfaces.eth0.useDHCP = lib.mkDefault true;  # overrides default networks in networkd profile

  systemd.network.wait-online.anyInterface = lib.mkOverride 500 false;  # 100 is default prio and 1000 is module default prio (changes default from networkd profile)

  systemd.network.networks = lib.mkIf config.networking.useNetworkd {
    # update settings from `networking.interfaces.eth0`-instantiated network
    "40-${config.networking.interfaces.eth0.name}" = {
      networkConfig = {
        IPv6PrivacyExtensions = lib.mkDefault false;
        IPv6AcceptRA = lib.mkDefault true;
      };

      dhcpV4Config = {
        ClientIdentifier = lib.mkDefault "mac";
      };
    };
  };
}
