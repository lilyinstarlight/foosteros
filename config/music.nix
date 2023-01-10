{ config, lib, pkgs, ... }:

{
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
      ] ++ (lib.optionals nixosConfig.nixpkgs.config.allowUnfree [ /*mopidy-spotify*/ ]);
    };

    programs.beets = {
      enable = true;
      settings = {
        directory = config.services.mopidy.settings.local.media_dir;
      };
    };
  };
}
