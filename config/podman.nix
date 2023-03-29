{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.podman {
  virtualisation.podman = {
    enable = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  home-manager.sharedModules = [
    ({ pkgs, ... }: {
      xdg.dataFile."containers/storage/networks/podman.json".source = let
        json = pkgs.formats.json {};
      in json.generate "podman.json" ({
          dns_enabled = true;
          driver = "bridge";
          id = "0000000000000000000000000000000000000000000000000000000000000000";
          internal = false;
          ipam_options = { driver = "host-local"; };
          ipv6_enabled = false;
          name = "podman";
          network_interface = "podman0";
          subnets = [{ gateway = "10.88.0.1"; subnet = "10.88.0.0/16"; }];
        });
    })
  ];

  virtualisation.containers.registries.search = [ "docker.io" ];

  environment.systemPackages = with pkgs; [
    podman-compose
  ];
}
