{ config, lib, pkgs, ... }:

{
  virtualisation.podman.enable = true;

  virtualisation.containers.registries.search = [ "docker.io" ];
  virtualisation.containers.containersConf.cniPlugins = with pkgs; [ dnsname-cni ];
}
