{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-12th-gen-intel
  ];

  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1 emulate_invalid_guest_state=0
    options kvm ignore_msrs=1 report_ignored_msrs=0
  '';

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  boot.initrd.systemd.extraBin = {
    find = "${pkgs.findutils}/bin/find";
    sed = "${pkgs.busybox}/bin/sed";
    xargs = "${pkgs.findutils}/bin/xargs";
  };

  # TODO: See both of these for context
  #   * https://github.com/systemd/systemd/issues/24904#issuecomment-1328607139
  #   * https://github.com/systemd/systemd/issues/3551
  boot.initrd.systemd.targets.initrd-root-device = {
    requires = [ "dev-nixos-root.device" ];
    after = [ "dev-nixos-root.device" ];
  };
  boot.initrd.systemd.targets.initrd-root-fs = {
    after = [ "sysroot.mount" ];
  };

  boot.initrd.systemd.services.create-root = {
    description = "Rolling over and creating new filesystem root";

    requires = [ "initrd-root-device.target" ];
    after = [ "initrd-root-device.target" ];
    requiredBy = [ "initrd-root-fs.target" ];
    before = [ "sysroot.mount" ];

    unitConfig = {
      AssertPathExists = "/etc/initrd-release";
      DefaultDependencies = false;
    };

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      mkdir -p /run/rootvol
      mount -t btrfs -o rw,subvol=/ /dev/nixos/root /run/rootvol

      num="$(printf '%s\n' "$(find /run/rootvol -mindepth 1 -maxdepth 1 -type d -name 'root-*')" | sed -e 's#^\s*$#0#' -e 's#^/run/rootvol/root-\(.*\)$#\1#' | sort -n | tail -n 1 | xargs -I '{}' expr 1 + '{}')"

      mv /run/rootvol/root /run/rootvol/root-"$num"
      btrfs property set /run/rootvol/root-"$num" ro true

      btrfs subvolume create /run/rootvol/root
      btrfs subvolume set-default /run/rootvol/root

      find /run/rootvol -mindepth 1 -maxdepth 1 -type d -name 'root-*' | sed -e 's#^/run/rootvol/root-\(.*\)$#\1#' | sort -n | head -n -30 | xargs -I '{}' sh -c "btrfs property set '/run/rootvol/root-{}' ro false && btrfs subvolume list -o '/run/rootvol/root-{}' | cut -d' ' -f9- | xargs -I '[]' btrfs subvolume delete '/run/rootvol/[]' && btrfs subvolume delete '/run/rootvol/root-{}'"

      umount /run/rootvol
      rmdir /run/rootvol
    '';
  };

  disko.devices = {
    disk.nvme0n1 = {
      type = "disk";
      device = "/dev/nvme0n1";
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
            name = "nixos";
            start = "100MiB";
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
            type = "lvm_lv";
            size = "100%FREE";
            content = {
              type = "btrfs";
              mountpoint = "/rootvol";
              subvolumes = {
                "/root" = {
                  mountpoint = "/";
                };
                "/nix" = {};
                "/state" = {};
                "/persist" = {};
              };
              mountOptions = [ "noauto" ];
            };
          };
          swap = {
            type = "lvm_lv";
            name = "swap";
            size = "16g";
            content = {
              type = "luks";
              name = "swap";
              keyFile = "/state/etc/ssh/ssh_host_rsa_key";
              content = {
                type = "swap";
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/state".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
}
