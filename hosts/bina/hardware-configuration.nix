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

  fileSystems."/" = {
    device = "/dev/disk/by-label/root";
    fsType = "btrfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/esp";
    fsType = "vfat";
  };

  swapDevices = [
    {
      device = "/dev/disk/by-label/swap";
    }
  ];

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

  nix.maxJobs = lib.mkDefault 4;
}
