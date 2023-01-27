{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-12th-gen-intel
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];

  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelParams = [ "i915.fastboot=1" ];
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1 emulate_invalid_guest_state=0
    options kvm ignore_msrs=1 report_ignored_msrs=0
  '';

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  system.devices = {
    rootDisk = "/dev/nvme0n1";
    coreThermalZone = 7;
    batteryId = 1;
    wirelessAdapter = "wlp166s0";
    backupAdapter = "enp0s13f0u2c2";
  };
}
