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

  boot.initrd.systemd.services.ensure-machine-id = {
    description = "Ensure machine-id Existence";

    requires = [ "initrd-root-device.target" ];
    after = [ "local-fs-pre.target" "initrd-root-device.target" ];
    requiredBy = [ "initrd-root-fs.target" ];
    before = [ "sysroot.mount" ];

    unitConfig = {
      AssertPathExists = "/etc/initrd-release";
      DefaultDependencies = false;
    };

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      mkdir -p /run/statevol
      mount -t btrfs -o rw,subvol=/state ${lib.escapeShellArg (if config.fileSystems."/state" ? device then config.fileSystems."/state".device else "/dev/disk/by-label/${config.fileSystems."/state".label}")} /run/statevol

      if ! [ -f /run/statevol/etc/machine-id ]; then
        printf 'uninitialized\n' >/run/statevol/etc/machine-id
      fi

      umount /run/statevol
      rmdir /run/statevol
    '';
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
