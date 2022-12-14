{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  config = {
    boot.kernelParams = lib.mkAfter [ "noquiet" ];
    # TODO: installer does not support systemd initrd yet
    boot.initrd.systemd.enable = lib.mkImageMediaOverride false;

    isoImage.isoName = lib.mkForce "foosteros.iso";
  };
}
