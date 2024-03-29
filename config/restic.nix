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
    (lib.mkIf (config.networking.networkmanager.enable && config.system.devices.backupAdapter == null) {
      path = [ pkgs.jq ];
      serviceConfig.ExecCondition = pkgs.writeShellScript "networkmanager-metered-check" ''
        set -euo pipefail
        busctl -j get-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.NetworkManager Connectivity \
          | jq -e '.data == 4' >/dev/null
        busctl -j get-property org.freedesktop.NetworkManager /org/freedesktop/NetworkManager org.freedesktop.NetworkManager Metered \
          | jq -e '.data != 1 and .data != 3' >/dev/null
      '';
    })
    (lib.mkIf (config.networking.networkmanager.enable && config.system.devices.backupAdapter != null) {
      serviceConfig.ExecCondition = "${pkgs.networkmanager}/bin/nmcli device connect ${config.system.devices.backupAdapter}";
    })
    (lib.mkIf (config.networking.useNetworkd && config.system.devices.backupAdapter != null) {
      serviceConfig.ExecCondition = "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --interface=${config.system.devices.backupAdapter}:routable --timeout=5";
    })
  ];
}
