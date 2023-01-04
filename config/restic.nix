{ config, lib, pkgs, ... }:

{
  # TODO: perform fs snapshot if we can
  services.restic.backups.${config.networking.hostName} = {
    initialize = true;
    repository = "b2:${lib.replaceStrings ["."] ["-"] config.networking.fqdn}-backup";
    paths = [
      "/state"
    ];
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
      "--keep-yearly 2"
    ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };

  systemd.services."restic-backups-${config.networking.hostName}" = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };
}
