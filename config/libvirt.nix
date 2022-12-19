{ config, lib, pkgs, ... }:

{
  virtualisation.kvmgt.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu.package = pkgs.qemu_kvm;
  };

  environment.systemPackages = with pkgs; lib.optionals (config.services.xserver.displayManager.sessionData.sessionNames != []) [
    virt-manager
  ];
}
