{ config, lib, pkgs, modulesPath, ... }:

{
  boot.initrd.kernelModules = [ "dm-snapshot" ];

  boot.initrd.luks.devices."nixos".device = "/dev/disk/by-partlabel/nixos";

  fileSystems."/" = {
    device = "/dev/disk/by-label/root";
    fsType = "btrfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/esp";
    fsType = "vfat";
  };

  swapDevices = [
    {
      device = "/dev/disk/by-label/swap";
    }
  ];
}
