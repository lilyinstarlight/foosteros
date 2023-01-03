{ config, lib, pkgs, ... }:

{
  boot.kernel.sysctl."kernel.sysrq" = lib.mkDefault 116;
}
