{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.sysrq {
  boot.kernel.sysctl."kernel.sysrq" = lib.mkDefault 116;
}
