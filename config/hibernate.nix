{ config, lib, pkgs, ... }:

{
  boot.resumeDevice = let
      eligibleSwaps = (map (swap: if swap ? device then swap.device else "/dev/disk/by-label/${swap.label}")
        (lib.filter (swap: lib.hasPrefix "/dev/" swap.device && !swap.randomEncryption.enable && !(lib.hasPrefix "/dev/zram" swap.device)) config.swapDevices));
    in lib.mkIf ((lib.length eligibleSwaps) > 0) (lib.mkDefault (lib.head eligibleSwaps));

  services.logind.lidSwitch = lib.mkDefault "suspend-then-hibernate";

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
  '';
}
