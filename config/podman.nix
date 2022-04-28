{ config, lib, pkgs, ... }:

{
  virtualisation.podman = {
    enable = true;
    defaultNetwork.dnsname.enable = true;
  };

  virtualisation.containers.registries.search = [ "docker.io" ];
}
