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
        mopidy-local mopidy-iris mopidy-mpd
      ] ++ (lib.optionals config.nixpkgs.config.allowUnfree [ /*mopidy-spotify*/ ]);
    };

    services.mpdris2 = {
      enable = true;
      notifications = true;
      multimediaKeys = false;
      cdPrevious = true;
      mpd.musicDirectory = cfg.services.mopidy.settings.local.media_dir;
    };

    systemd.user.services.mpdris2 = {
      # wait for mako since mpdris2 disables notifications if the org.freedesktop.Notifications busname is not available yet
      Unit.After = [ "mako.service" ];
      # wait for mpd port to become available to avoid reconnected notification on bootup
      Service.ExecStartPre = "${pkgs.coreutils}/bin/timeout 60 ${pkgs.bash}/bin/sh -c 'while ! ${pkgs.iproute2}/sbin/ss -tlnH sport = :${toString cfg.services.mpdris2.mpd.port} | ${pkgs.gnugrep}/bin/grep -q \"^LISTEN.*:${toString cfg.services.mpdris2.mpd.port}\"; do ${pkgs.coreutils}/bin/sleep 1; done'";
    };

    programs.beets = {
      enable = true;
      settings = {
        directory = cfg.services.mopidy.settings.local.media_dir;
      };
    };
  };
}
