{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.gnupg {
  programs.gnupg.agent.enable = true;


  preservation.preserveAt = lib.mkIf (config.preservation.enable && (config.users.users.lily.enable or false)) {
    ${config.system.devices.preservedState} = {
      users.lily = {
        directories = [
          { directory = ".gnupg"; mode = "0700"; }
        ];
      };
    };
  };
}
