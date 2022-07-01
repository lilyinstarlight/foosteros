{ config, lib, pkgs, modulesPath, ... }:

{
  fileSystems."/" = {
    label = "root";
    fsType = "btrfs";
  };

  fileSystems."/boot" = {
    label = "esp";
    fsType = "vfat";
  };

  swapDevices = [
    {
      label = "swap";
    }
  ];
}
