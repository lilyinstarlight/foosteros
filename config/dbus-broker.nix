{ config, lib, pkgs, ... }:

{
  services.dbus.implementation = "broker";
}
