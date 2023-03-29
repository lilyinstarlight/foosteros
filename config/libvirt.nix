{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.libvirt {
  virtualisation.kvmgt.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu.package = pkgs.qemu_kvm;
  };

  environment.systemPackages = with pkgs; lib.optionals (config.services.xserver.displayManager.sessionData.sessionNames != []) [
    virt-manager
  ];
}
