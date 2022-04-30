{ config, lib, pkgs, modulesPath, ... }:

{
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "dm-snapshot" "i915" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1 emulate_invalid_guest_state=0
    options kvm ignore_msrs=1 report_ignored_msrs=0
  '';

  boot.initrd.luks.devices."nixos".device = "/dev/disk/by-partlabel/nixos";

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir -p /mnt-root
    mount -t btrfs -o rw,subvol=/ /dev/disk/by-label/root /mnt-root

    num="$(printf '%s\n' "$(find /mnt-root -mindepth 1 -maxdepth 1 -type d -name 'root-*')" | sed -e 's#^\s*$#0#' -e 's#^/mnt-root/root-\(.*\)$#\1#' | sort -n | tail -n 1 | xargs -I '{}' expr 1 + '{}')"

    mv /mnt-root/root /mnt-root/root-"$num"
    btrfs property set /mnt-root/root-"$num" ro true

    btrfs subvolume create /mnt-root/root
    btrfs subvolume set-default /mnt-root/root

    find /mnt-root -mindepth 1 -maxdepth 1 -type d -name 'root-*' | sed -e 's#^/mnt-root/root-\(.*\)$#\1#' | sort -n | head -n -30 | xargs -I '{}' sh -c "btrfs property set '/mnt-root/root-{}' ro false && btrfs subvolume list -o '/mnt-root/root-{}' | cut -d' ' -f9- | xargs -I '[]' btrfs subvolume delete '/mnt-root/[]' && btrfs subvolume delete '/mnt-root/root-{}'"

    umount /mnt-root
  '';

  fileSystems."/" = {
    label = "root";
    fsType = "btrfs";
    options = [
      "subvol=/root"
    ];
  };

  fileSystems."/nix" = {
    label = "root";
    fsType = "btrfs";
    options = [
      "subvol=/nix"
    ];
  };

  fileSystems."/state" = {
    label = "root";
    fsType = "btrfs";
    options = [
      "subvol=/state"
    ];
    neededForBoot = true;
  };

  fileSystems."/persist" = {
    label = "root";
    fsType = "btrfs";
    options = [
      "subvol=/persist"
    ];
    neededForBoot = true;
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

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
}
