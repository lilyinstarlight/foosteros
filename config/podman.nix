{ config, lib, pkgs, ... }:

{
  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.containers.registries.search = [ "docker.io" ];

  environment.systemPackages = with pkgs; [
    podman-compose
  ];
}
