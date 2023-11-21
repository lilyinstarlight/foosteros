{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.music {
  environment.systemPackages = with pkgs; [
    # TODO: re-add beets once NixOS/nixpkgs#268598 is merged
    ncmpcpp #beets
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
        mopidy-local mopidy-iris mopidy-mpris mopidy-notify mopidy-mpd mopidy-spotify
      ];
    };

    programs.beets = {
      # TODO: re-add beets once NixOS/nixpkgs#268598 is merged
      #enable = true;
      settings = {
        directory = config.services.mopidy.settings.local.media_dir;
      };
    };
  };
}
