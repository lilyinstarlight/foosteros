{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.adb {
  services.udev.packages = with pkgs; [
    android-udev-rules
  ];

  users.groups.adbusers = {};
}
