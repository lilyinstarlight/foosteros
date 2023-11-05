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
        mopidy-local mopidy-iris mopidy-mpris mopidy-notify mopidy-mpd #mopidy-spotify
        #TODO: remove and restore above when NixOS/nixpkgs#265688 is merged
        (mopidy-spotify.overrideAttrs (attrs: {
          version = "unstable-2023-11-01";
          src = fetchFromGitHub {
            owner = "mopidy";
            repo = "mopidy-spotify";
            rev = "48faaaa2642647b0152231798b46ccd9631694f5";
            hash = "sha256-RwkUdcbDU7/ndVnPteG/iXB2dloljvCHQlvPk4tacuA=";
          };
        }))
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
