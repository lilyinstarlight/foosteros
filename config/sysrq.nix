{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.sysrq {
  # unraw (r), sync (s), remount read-only (u), oom_kill (f), reboot (b)
  boot.kernel.sysctl."kernel.sysrq" = lib.mkDefault 244;
}
