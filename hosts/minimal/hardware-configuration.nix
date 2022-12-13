{ config, lib, pkgs, ... }:

{
  disko.devices = {
    disk.sda = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            type = "partition";
            name = "esp";
            start = "1MiB";
            end = "100MiB";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          }
          {
            type = "partition";
            name = "root";
            start = "100MiB";
            end = "-2GiB";
            part-type = "primary";
            content = {
              type = "filesystem";
              format = "btrfs";
              mountpoint = "/";
            };
          }
          {
            type = "partition";
            name = "swap";
            start = "-2GiB";
            end = "100%";
            part-type = "primary";
            content = {
              type = "swap";
            };
          }
        ];
      };
    };
  };
}
