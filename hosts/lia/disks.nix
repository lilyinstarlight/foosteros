{ config, lib, pkgs, ... }:

{
  disko.devices = {
    disk.${lib.removePrefix "/dev/" config.system.devices.rootDisk} = {
      device = "${config.system.devices.rootDisk}";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "esp";
            start = "1MiB";
            end = "512MiB";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          }
          {
            name = "nixos";
            start = "512MiB";
            end = "100%";
            content = {
              type = "luks";
              name = "nixos";
              content = {
                type = "lvm_pv";
                vg = "nixos";
              };
            };
          }
        ];
      };
    };

    lvm_vg = {
      nixos = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "468g";
            content = {
              type = "btrfs";
              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                };
                "/nix" = {};
                "/state" = {};
                "/persist" = {};
              };
            };
          };
          swap = {
            name = "swap";
            size = "100%FREE";
            content = {
              type = "swap";
            };
          };
        };
      };
    };
  };

  fileSystems."/state".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
}
