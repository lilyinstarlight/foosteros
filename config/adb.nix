{ config, lib, pkgs, ... }:

{
  services.udev.packages = with pkgs; [
    android-udev-rules
  ];

  users.groups.adbusers = {};
}
