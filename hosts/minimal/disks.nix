{ config, lib, pkgs, ... }:

{
  disko.devices = {
    disk.sda = {
      device = "/dev/sda";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            label = "esp";
            type = "EF00";
            start = "1MiB";
            end = "100MiB";
            content = {
              type = "filesystem";
              format = "vfat";
              mountOptions = [ "umask=0077" ];
              mountpoint = "/boot";
            };
          };
          root = {
            label = "root";
            start = "100MiB";
            end = "-2GiB";
            content = {
              type = "filesystem";
              format = "btrfs";
              mountpoint = "/";
            };
          };
          swap = {
            label = "swap";
            start = "-2GiB";
            end = "100%";
            content = {
              type = "swap";
            };
          };
        };
      };
    };
  };
}
