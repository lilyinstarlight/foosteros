{ config, lib, utils, pkgs, ... }:

{
  imports = [
    ./disks.nix
    ./hardware.nix
  ];

  foosteros.profiles = {
    lily = true;

    restic = true;

    adb = true;
    alien = true;
    azure = true;
    bluetooth = true;
    cosmic = true;
    ephemeral = true;
    fcitx5 = true;
    fwupd = true;
    gc = true;
    gnupg = true;
    hibernate = true;
    homebins = true;
    hyfetch = true;
    ledger = true;
    libvirt = true;
    lsp = true;
    miracast = true;
    music = true;
    networkmanager = true;
    nullmailer = true;
    pass = true;
    pki = true;
    podman = true;
    secureboot = true;
    steam = true;
    udiskie = true;
    workstation = true;
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [];
    gnupg.sshKeyPaths = [ "/state/etc/ssh/ssh_host_rsa_key" ];
    secrets = {
      root-password = {
        neededForUsers = true;
      };
      lily-password = {
        neededForUsers = true;
      };
      josie-password = {
        neededForUsers = true;
      };
      restic-backup-password = {};
      restic-backup-environment = {};
      dnsimple-ddns = {};
      nullmailer-remotes = {
        mode = "0440";
        group = config.services.nullmailer.group;
        restartUnits = [ "nullmailer.service" ];
      };
      mopidy-lily-secrets = {
        mode = "0400";
        owner = config.users.users.lily.name;
        group = config.users.users.lily.group;
      };
    } // (let
      mkNmSecret = name: lib.nameValuePair "networks/${name}" {
        restartUnits = [ "NetworkManager.service" ];
      };
    in lib.listToAttrs (map mkNmSecret [
      "home"
      "admin"
      "mobile"
      "wired"
      "wired-admin"
      "josie"
    ]));
  };

  preservation = {
    enable = true;
    preserveAt = {
      "/state" = {
        directories = [
          "/etc/nixos"
          "/etc/secureboot"
          { directory = "/home/josie"; user = "josie"; group = "users"; }
          "/var/db/sudo"
          "/var/lib/bluetooth"
          "/var/lib/libvirt"
          { directory =  "/var/lib/nixos"; inInitrd = true; }
          "/var/lib/systemd"
          "/var/lib/tpm"
          "/var/log"
        ];
        files = [
          { file = "/etc/machine-id"; inInitrd = true; how = "symlink"; }
          { file = "/etc/ssh/ssh_host_ed25519_key"; mode = "0700"; inInitrd = true; }
          { file = "/etc/ssh/ssh_host_ed25519_key.pub"; inInitrd = true; }
          { file = "/etc/ssh/ssh_host_rsa_key"; mode = "0700"; inInitrd = true; }
          { file = "/etc/ssh/ssh_host_rsa_key.pub"; inInitrd = true; }
        ];
        users.lily = {
          directories = [
            "docs"
            "emu"
            "music"
            "pics"
            "public"
            "src"
            "vids"
            ".azure"
            ".backgrounds"
            ".config/dconf"
            ".config/Element"
            ".config/Mattermost"
            ".config/obs-studio"
            ".config/pipewire"
            ".config/PrusaSlicer"
            ".config/qutebrowser"
            ".config/rncbc.org"
            ".config/teams-for-linux"
            ".config/WebCord"
            { directory = ".gnupg"; mode = "0700"; }
            ".local/share/fish"
            ".local/share/mopidy"
            ".local/share/nvim"
            ".local/share/qutebrowser"
            ".local/state/wireplumber"
            ".mozilla"
            ".password-store"
            ".Playdate Simulator"
            ".sonic-pi"
            { directory = ".ssh"; mode = "0700"; }
          ];
          files = [
            { file = ".android/adbkey"; configureParent = true; }
            { file = ".android/adbkey.pub"; configureParent = true; }
            { file = ".config/beets/library.db"; configureParent = true; }
            { file = ".config/beets/state.pickle"; configureParent = true; }
            ".lmmsrc.xml"
          ];
        };
      };

      "/persist" = {
        users.lily = {
          directories = [
            "iso"
            "tmp"
            { directory = ".cargo/registry"; configureParent = true; }
          ];
        };
      };
    };
  };

  systemd.tmpfiles.settings.preservation = {
    "/home/lily/.config".d = { user = "lily"; group = "users"; mode = "0755"; };
    "/home/lily/.local".d = { user = "lily"; group = "users"; mode = "0755"; };
    "/home/lily/.local/share".d = { user = "lily"; group = "users"; mode = "0755"; };
    "/home/lily/.local/state".d = { user = "lily"; group = "users"; mode = "0755"; };
  };

  systemd.services.systemd-machine-id-commit = {
    unitConfig.ConditionPathIsMountPoint = [
      "" "/state/etc/machine-id"
    ];
    serviceConfig.ExecStart = [
      "" "systemd-machine-id-setup --commit --root /state"
    ];
  };

  networking = {
    hostName = "lia";
    domain = "fooster.network";
  };

  boot.initrd.services.udev.rules = ''
    ACTION=="add", KERNEL=="tpm[0-9]*", TAG+="systemd"
  '';

  boot.initrd.systemd = {
    extraBin = {
      nv_readvalue = "${pkgs.tpm-luks}/usr/bin/nv_readvalue";
    };

    services.unlock-with-tpm12-key = {
      description = "Unlock LUKS with TPM 1.2 key";

      requires = [ "dev-tpm0.device" "${utils.escapeSystemdPath config.boot.initrd.luks.devices.nixos.device}.device"];
      after = [ "dev-tpm0.device" "${utils.escapeSystemdPath config.boot.initrd.luks.devices.nixos.device}.device" ];
      wantedBy = [ "initrd-root-device.target" ];
      before = [ "systemd-cryptsetup@${config.boot.initrd.luks.devices.nixos.name}.service" "initrd-root-device.target" ];

      unitConfig = {
        AssertPathExists = "/etc/initrd-release";
        DefaultDependencies = false;
      };

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        touch /dev/shm/luks-key
        chmod a=,u=r /dev/shm/luks-key
        nv_readvalue -ix 2 -sz 32 -of /dev/shm/luks-key
        systemd-cryptsetup attach ${config.boot.initrd.luks.devices.nixos.name} ${config.boot.initrd.luks.devices.nixos.device} /dev/shm/luks-key
        shred -fu /dev/shm/luks-key
      '';
    };
  };

  services.restic.backups.lia = {
    passwordFile = config.sops.secrets.restic-backup-password.path;
    environmentFile = config.sops.secrets.restic-backup-environment.path;
  };

  virtualisation.spiceUSBRedirection.enable = true;

  nix = {
    settings = {
      keep-outputs = true;
      max-jobs = "auto";
    };
  };

  environment.etc = lib.mapAttrs'
    (name: value: lib.nameValuePair "NetworkManager/system-connections/${lib.removePrefix "networks/" name}" { source = value.path; })
    (lib.filterAttrs (name: value: lib.hasPrefix "networks/" name) config.sops.secrets);

  services.logind.lidSwitch = "ignore";

  services.resolved.dnssec = "false";

  services.tcsd.enable = true;

  services.nullmailer.remotesFile = config.sops.secrets.nullmailer-remotes.path;
  systemd.services.nullmailer.serviceConfig = {
    SupplementaryGroups = [ config.users.groups.keys.name ];
  };

  services.dnsimple-ddns = {
    enable = true;
    configFile = config.sops.secrets.dnsimple-ddns.path;
  };

  services.logmail = {
    enable = true;
    settings = {
      mailfrom = "logs@fooster.network";
      mailto = "logs@fooster.network";
      subject = "Logs for %h at %F %R";
    };
    filter = ''
      kernel: DMAR: \[Firmware Bug\]: No firmware reserved region can cover this RMRR \[0x00000000cd800000-0x00000000cfffffff\], contact BIOS vendor for fixes
      kernel: ACPI Error: Needed type \[Reference\], found \[Integer\] [0-9a-f]\{16\} ([0-9]\{8\}/exresop-[0-9]*)
      kernel: ACPI Error: AE_AML_OPERAND_TYPE, While resolving operands for \[OpcodeName unavailable\] ([0-9]\{8\}/dswexec-[0-9]*)
      kernel: ACPI Error: Aborting method \\_PR\.CPU0\._PDC due to previous error (AE_AML_OPERAND_TYPE) ([0-9]\{8\}/psparse-[0-9]*)
      kernel: i915 [0-9]\{4\}:[0-9]\{2\}:[0-9]\{2\}.[0-9]: \[drm\] \*ERROR\* Failed to write source OUI
      systemd-udevd\[[0-9]*\]: /nix/store/[0-9a-z]\{32\}-systemd-[^/]*/lib/udev/rules\.d/50-udev-default\.rules:[0-9]* Unknown group '[^']*', ignoring
      kernel: Bluetooth: hci0: unexpected event for opcode 0xfc2f
      kernel: Bluetooth: hci0: SCO packet for unknown connection handle [0-9]*
      bluetoothd\[[0-9]*\]: profiles/sap/server\.c:sap_server_register() Sap driver initialization failed\.
      bluetoothd\[[0-9]*\]: sap-server: Operation not permitted (1)
      pipewire\[[0-9]*\]: jack-device 0x[0-9a-f]\{12\}: can't open client: Input/output error
      dbus-broker-launch\[[0-9]*\]: Ignoring duplicate name '[^']*' in service file '[^']*'
    '';
  };

  users = {
    mutableUsers = false;
    users = {
      root.hashedPasswordFile = config.sops.secrets.root-password.path;
      lily = {
        hashedPasswordFile = config.sops.secrets.lily-password.path;
        extraGroups = with config.users.groups; map (grp: grp.name) [ networkmanager keys adbusers ];
      };
      josie = {
        description = "Josie Wirszyla";
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.josie-password.path;
        extraGroups = with config.users.groups; map (grp: grp.name) [ wheel networkmanager ];
      };
    };
  };

  home-manager.users.lily = { pkgs, lib, ... }: {
    services.mopidy.extraConfigFiles = [ config.sops.secrets.mopidy-lily-secrets.path ];
  };

  system.stateVersion = "23.11";
}
