{ config, lib, pkgs, modulesPath, ... }:

{
  boot.initrd.kernelModules = [ "dm-snapshot" ];

  boot.initrd.luks.devices."nixos".device = "/dev/disk/by-partlabel/nixos";

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
