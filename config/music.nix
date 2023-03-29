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
        # TODO: remove when mopidy-spotify is available again
        #mopidy-local mopidy-iris mopidy-mpris mopidy-notify mopidy-mpd mopidy-spotify
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
}
