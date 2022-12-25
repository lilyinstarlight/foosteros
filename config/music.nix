{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ncmpcpp beets
    rofi-mpd
  ];

  # only for user lily
  home-manager.users.lily = { pkgs, lib, ... }: let cfg = config.home-manager.users.lily; in {
    services.mopidy = {
      enable = true;
      settings = {
        file.enabled = false;
        local.media_dir = "${cfg.home.homeDirectory}/music";
      };
      extensionPackages = with pkgs; [
        mopidy-local mopidy-iris mopidy-mpris mopidy-notify mopidy-mpd
      ] ++ (lib.optionals config.nixpkgs.config.allowUnfree [ /*mopidy-spotify*/ ]);
    };

    programs.beets = {
      enable = true;
      settings = {
        directory = cfg.services.mopidy.settings.local.media_dir;
      };
    };
  };
}
