{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.music {
  environment.systemPackages = with pkgs; [
    ncmpcpp beets
    rofi-mpd
  ];

  # only for user lily
  home-manager.users.lily = { config, lib, pkgs, nixosConfig, ... }: {
    services.mopidy = {
      enable = true;
      settings = {
        file.enabled = false;
        local.media_dir = "${config.home.homeDirectory}/music";
      };
      extensionPackages = with pkgs; [
        mopidy-local mopidy-iris mopidy-mpris mopidy-notify mopidy-mpd
      ];
    };

    programs.beets = {
      enable = true;
      settings = {
        directory = config.services.mopidy.settings.local.media_dir;
      };
    };
  };

  preservation.preserveAt = lib.mkIf (config.preservation.enable && (config.users.users.lily.enable or false)) {
    ${config.system.devices.preservedState} = {
      users.lily = {
        directories = [
          ".local/share/mopidy"
        ];
        files = [
          { file = ".config/beets/library.db"; configureParent = true; }
          { file = ".config/beets/state.pickle"; configureParent = true; }
        ];
      };
    };
  };
}
