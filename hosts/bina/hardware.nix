{ config, lib, pkgs, inputs, ... }:

{
  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];

  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1 emulate_invalid_guest_state=0
    options kvm ignore_msrs=1 report_ignored_msrs=0
  '';

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  nixpkgs.hostPlatform = "x86_64-linux";

  system.devices = {
    rootDisk = "/dev/nvme0n1";
    coreThermalZone = 7;
    batteryId = 1;
    wirelessAdapter = "wlp166s0";
    preservedState = "/state";
    persistedState = "/persist";
    monitorFontSize = 32;
  };
}
