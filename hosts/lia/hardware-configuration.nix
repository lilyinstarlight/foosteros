{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ "dm-snapshot" "i915" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1 emulate_invalid_guest_state=0
    options kvm ignore_msrs=1 report_ignored_msrs=0
  '';

  # TODO: use disko for lia
  boot.initrd.luks.devices."nixos".device = "/dev/disk/by-partlabel/nixos";

  boot.initrd.systemd.extraBin = {
    find = "${pkgs.findutils}/bin/find";
    sed = "${pkgs.busybox}/bin/sed";
    xargs = "${pkgs.findutils}/bin/xargs";
  };

  # TODO: See both of these for context
  #   * https://github.com/systemd/systemd/issues/24904#issuecomment-1328607139
  #   * https://github.com/systemd/systemd/issues/3551
  boot.initrd.systemd.targets.initrd-root-device = {
    requires = [ "dev-disk-by\\x2dlabel-root.device" ];
    after = [ "dev-disk-by\\x2dlabel-root.device" ];
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
      mount -t btrfs -o rw,subvol=/ /dev/disk/by-label/root /run/rootvol

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