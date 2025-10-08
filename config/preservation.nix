{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.preservation {
  preservation = {
    enable = true;
    preserveAt = {
      ${config.system.devices.preservedState} = {
        directories = [
          "/etc/nixos"
          "/var/db/sudo"
          "/var/lib/systemd"
          { directory = "/var/lib/nixos"; inInitrd = true; }
          "/var/log"
        ];
        files = [
          { file = "/etc/machine-id"; inInitrd = true; how = "symlink"; }
          { file = "/etc/ssh/ssh_host_ed25519_key"; mode = "0700"; inInitrd = true; }
          { file = "/etc/ssh/ssh_host_ed25519_key.pub"; inInitrd = true; }
          { file = "/etc/ssh/ssh_host_rsa_key"; mode = "0700"; inInitrd = true; }
          { file = "/etc/ssh/ssh_host_rsa_key.pub"; inInitrd = true; }
        ];
      };
    };
  };

  systemd.services.systemd-machine-id-commit = {
    unitConfig.ConditionPathIsMountPoint = [
      "" "/state/etc/machine-id"
    ];
    serviceConfig.ExecStart = [
      "" "systemd-machine-id-setup --commit --root /state"
    ];
  };

}
