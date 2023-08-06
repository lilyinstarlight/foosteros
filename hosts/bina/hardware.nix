{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-12th-gen-intel
  ];

  # TODO: remove when NixOS/nixpkgs#243242 is merged
  systemd.package = inputs.systemd-254.legacyPackages.${pkgs.stdenv.hostPlatform.system}.systemd;
  boot.initrd.systemd.package = inputs.systemd-254.legacyPackages.${pkgs.stdenv.hostPlatform.system}.systemdStage1;
  boot.initrd.systemd.suppressedUnits = [ "systemd-hibernate-resume@.service" ];

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
    monitorFontSize = 32;
  };
}
