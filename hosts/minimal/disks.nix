{ config, lib, pkgs, ... }:

{
  disko.devices = {
    disk.sda = {
      device = "/dev/sda";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            priority = 1;
            label = "esp";
            type = "ef00";
            start = "1MiB";
            size = "100M";
            content = {
              type = "filesystem";
              format = "vfat";
              mountOptions = [ "umask=0077" ];
              mountpoint = "/boot";
            };
          };
          root = {
            priority = 2;
            label = "root";
            end = "-2GiB";
            content = {
              type = "filesystem";
              format = "btrfs";
              mountpoint = "/";
            };
          };
          swap = {
            priority = 3;
            label = "swap";
            size = "100%";
            content = {
              type = "swap";
            };
          };
        };
      };
    };
  };
}
