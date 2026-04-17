{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.cad {
  environment.systemPackages = with pkgs; [
    freecad prusa-slicer
    kicad-small
  ];

  preservation.preserveAt = lib.mkIf (config.preservation.enable && (config.users.users.lily.enable or false)) {
    ${config.system.devices.preservedState} = {
      users.lily = {
        directories = [
          ".config/PrusaSlicer"
        ];
      };
    };
  };
}
