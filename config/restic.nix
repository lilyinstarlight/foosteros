{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.restic {
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
        OnCalendar = lib.mkDefault "daily";
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

  systemd.services."restic-backups-${config.networking.hostName}" = lib.mkMerge [
    {
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      path = [ pkgs.btrfs-progs ];
    }
    (lib.mkIf (config.system.devices.backupAdapter != null && config.networking.networkmanager.enable) {
      serviceConfig.ExecCondition = "${pkgs.networkmanager}/bin/nmcli device connect ${config.system.devices.backupAdapter}";
    })
    (lib.mkIf (config.system.devices.backupAdapter != null && config.networking.useNetworkd) {
      serviceConfig.ExecCondition = "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --interface=${config.system.devices.backupAdapter}:routable --timeout=5";
    })
  ];
}
