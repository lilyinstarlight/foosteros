{ config, lib, pkgs, ... }:

{
  services.restic.backups.${config.networking.hostName} = lib.mkMerge [
    {
      initialize = true;
      repository = "b2:${lib.replaceStrings ["."] ["-"] config.networking.fqdn}-backup";
      paths = [
        "/backup"
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
    }
    (lib.mkIf (config.fileSystems."/".fsType == "btrfs" && config.fileSystems."/state".fsType == "btrfs") {
      backupPrepareCommand = ''
        btrfs subvolume snapshot /state /backup
      '';
      backupCleanupCommand = ''
        btrfs subvolume delete /backup
      '';
    })
  ];

  systemd.services."restic-backups-${config.networking.hostName}" = {
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };
}
