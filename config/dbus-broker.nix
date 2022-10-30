{ config, lib, pkgs, ... }:

{
  services.dbus.enable = lib.mkOverride 75 false;  # 50 is force prio and 100 is default prio
  services.dbus-broker.enable = true;
}
