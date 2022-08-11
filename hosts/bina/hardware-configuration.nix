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

  boot.initrd.systemd.extraBin = {
    find = "${pkgs.findutils}/bin/find";
    sed = "${pkgs.busybox}/bin/sed";
    xargs = "${pkgs.findutils}/bin/xargs";
  };
  boot.initrd.systemd.targets.initrd-root-device = {
    requires = [ "dev-disk-by\\x2dlabel-root.device" ];
    after = [ "dev-disk-by\\x2dlabel-root.device" ];
  };
  boot.initrd.systemd.services.create-root = {
    description = "Rolling over and creating new filesystem root";

    requires = [ "initrd-root-device.target" ];
    after = [ "initrd-root-device.target" ];
    wantedBy = [ "sysroot.mount" "initrd-root-fs.target" ];
    before = [ "sysroot.mount" "initrd-root-fs.target" ];

    unitConfig = {
      DefaultDependencies = false;
    };

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
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
  };

  fileSystems."/" = {
    # TODO: revert once NixOS/nixpkgs#xxxxxx is merged
    # label = "root";
    device = "/dev/disk/by-label/root";
    fsType = "btrfs";
    options = [
      "subvol=/root"
    ];
  };

  fileSystems."/nix" = {
    # TODO: revert once NixOS/nixpkgs#xxxxxx is merged
    # label = "root";
    device = "/dev/disk/by-label/root";
    fsType = "btrfs";
    options = [
      "subvol=/nix"
    ];
  };

  fileSystems."/state" = {
    # TODO: revert once NixOS/nixpkgs#xxxxxx is merged
    # label = "root";
    device = "/dev/disk/by-label/root";
    fsType = "btrfs";
    options = [
      "subvol=/state"
    ];
    neededForBoot = true;
  };

  fileSystems."/persist" = {
    # TODO: revert once NixOS/nixpkgs#xxxxxx is merged
    # label = "root";
    device = "/dev/disk/by-label/root";
    fsType = "btrfs";
    options = [
      "subvol=/persist"
    ];
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    # TODO: revert once NixOS/nixpkgs#xxxxxx is merged
    # label = "esp";
    device = "/dev/disk/by-label/esp";
    fsType = "vfat";
  };

  swapDevices = [
    {
      # TODO: revert once NixOS/nixpkgs#xxxxxx is merged
      # label = "swap";
      device = "/dev/disk/by-label/swap";
    }
  ];

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
}
