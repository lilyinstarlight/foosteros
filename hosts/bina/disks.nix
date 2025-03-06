{ config, lib, pkgs, ... }:

{
  disko.devices = {
    disk.${lib.removePrefix "/dev/" config.system.devices.rootDisk} = {
      device = "${config.system.devices.rootDisk}";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            priority = 1;
            label = "esp";
            type = "ef00";
            start = "1MiB";
            size = "512M";
            content = {
              type = "filesystem";
              format = "vfat";
              mountOptions = [ "umask=0077" ];
              mountpoint = "/boot";
            };
          };
          nixos = {
            priority = 2;
            label = "nixos";
            size = "100%";
            content = {
              type = "luks";
              name = "nixos";
              content = {
                type = "lvm_pv";
                vg = "nixos";
              };
            };
          };
        };
      };
    };

    lvm_vg = {
      nixos = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "450g";
            content = {
              type = "btrfs";
              subvolumes = {
                "root" = {
                  mountpoint = "/";
                };
                "nix" = {
                  mountpoint = "/nix";
                };
                "state" = {
                  mountpoint = "/state";
                };
                "persist" = {
                  mountpoint = "/persist";
                };
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
