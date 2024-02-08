{ config, lib, pkgs, ... }:

{
  disko.devices = {
    disk.sda = {
      device = "/dev/sda";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "esp";
            start = "1MiB";
            end = "100MiB";
            content = {
              type = "filesystem";
              format = "vfat";
              mountOptions = [ "umask=0077" ];
              mountpoint = "/boot";
            };
          }
          {
            name = "root";
            start = "100MiB";
            end = "-2GiB";
            content = {
              type = "filesystem";
              format = "btrfs";
              mountpoint = "/";
            };
          }
          {
            name = "swap";
            start = "-2GiB";
            end = "100%";
            content = {
              type = "swap";
            };
          }
        ];
      };
    };
  };
}
