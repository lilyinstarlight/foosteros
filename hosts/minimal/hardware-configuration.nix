{ config, lib, pkgs, modulesPath, ... }:

{
  fileSystems."/" = {
    # TODO: revert once NixOS/nixpkgs#xxxxxx is merged
    # label = "root";
    device = "/dev/disk/by-label/root";
    fsType = "btrfs";
  };

  fileSystems."/boot" = {
    # TODO: revert once NixOS/nixpkgs#xxxxxx is merged
    # label = "esp";
    device = "/dev/disk/by-label/esp";
    fsType = "vfat";
  };

  swapDevices = [
    {
      # TODO: revert once NixOS/nixpkgs#xxxxxx is merged
      # label = "swap";
      device = "/dev/disk/by-label/swap";
    }
  ];
}
