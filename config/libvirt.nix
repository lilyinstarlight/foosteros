{ config, lib, pkgs, ... }:

{
  virtualisation.kvmgt.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu.package = pkgs.qemu_kvm;
  };
}
