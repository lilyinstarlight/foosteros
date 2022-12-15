{ config, lib, pkgs, ... }:

{
  systemd.network.networks."80-wl" = {
    name = "wl*";
    DHCP = "yes";

    dhcpV4Config = {
      ClientIdentifier = "mac";
      RouteMetric = 700;
    };
    dhcpV6Config = {
      RouteMetric = 700;
    };
    linkConfig = {
      RequiredForOnline = "no";
    };
    networkConfig = {
      IPv6PrivacyExtensions = "kernel";
    };
  };

  systemd.network.networks."80-en" = {
    name = "en*";
    DHCP = "yes";

    dhcpV4Config = {
      ClientIdentifier = "mac";
      RouteMetric = 200;
    };
    dhcpV6Config = {
      RouteMetric = 200;
    };
    linkConfig = {
      RequiredForOnline = "no";
    };
    networkConfig = {
      IPv6PrivacyExtensions = "kernel";
    };
  };
}
