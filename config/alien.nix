{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    inputs.envfs.nixosModules.envfs
  ];

  system.activationScripts.envfsfallback = ''
    mkdir -p /run/bindroot
    mount --bind --make-unbindable / /run/bindroot
    mkdir -m 0755 -p /run/bindroot/usr/bin
    ln -sfn ${config.environment.usrbinenv} /run/bindroot/usr/bin/env
    mkdir -m 0755 -p /run/bindroot/bin
    ln -sfn ${config.environment.binsh} /run/bindroot/bin/sh
    umount /run/bindroot
    rmdir /run/bindroot
  '';

  programs.nix-ld.enable = true;

  # TODO: remove override when checks are fixed
  environment.systemPackages = with inputs.nix-alien.packages.${pkgs.stdenv.hostPlatform.system}; [ (nix-alien.overrideAttrs (old: { doInstallCheck = false; })) ];
}
