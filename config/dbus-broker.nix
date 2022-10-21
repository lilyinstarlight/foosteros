{ config, lib, pkgs, ... }:

{
  services.dbus.enable = lib.mkForce false;
  services.dbus-broker.enable = true;
}
