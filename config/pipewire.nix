{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.pipewire {
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    pulse.enable = true;
    # TODO: consider manually doing this so JACK apps work from graphical launcher?
    # jack.enable = true;
  };

  preservation.preserveAt = lib.mkIf (config.preservation.enable && (config.users.users.lily.enable or false)) {
    ${config.system.devices.preservedState} = {
      users.lily = {
        directories = [
          ".config/pipewire"
          ".local/state/wireplumber"
        ];
      };
    };
  };
}
