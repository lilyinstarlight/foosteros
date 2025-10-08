{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.adb {
  services.udev.packages = with pkgs; [
    android-udev-rules
  ];

  users.groups.adbusers = {};

  preservation.preserveAt = lib.mkIf (config.preservation.enable && (config.users.users.lily.enable or false)) {
    ${config.system.devices.preservedState} = {
      users.lily = {
        files = [
          { file = ".android/adbkey"; configureParent = true; }
          { file = ".android/adbkey.pub"; configureParent = true; }
        ];
      };
    };
  };
}
