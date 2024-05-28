{ config, lib, pkgs, ... }:

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
    ]));
  };

  environment.persistence."/state" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/var/db/sudo"
      "/var/lib/bluetooth"
      "/var/lib/libvirt"
      "/var/lib/systemd"
      "/var/log"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
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
        ".gnupg"
        ".local/share/fish"
        ".local/share/mopidy"
        ".local/share/nvim"
        ".local/share/qutebrowser"
        ".local/state/wireplumber"
        ".mozilla"
        ".password-store"
        ".Playdate Simulator"
        ".sonic-pi"
        ".ssh"
      ];
      files = [
        ".android/adbkey"
        ".android/adbkey.pub"
        ".config/beets/library.db"
        ".config/beets/state.pickle"
        ".lmmsrc.xml"
      ];
    };
  };

  environment.persistence."/persist" = {
    hideMounts = true;
    users.lily = {
      directories = [
        "iso"
        "tmp"
        ".cargo/registry"
      ];
    };
  };

  networking = {
    hostName = "lia";
    domain = "fooster.network";
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

  environment.etc = {
    "sway/config.d/lia".text = ''
      ### ouputs
      output eDP-1 resolution 1920x1080 position 0 0 scale 1

      ### inputs
      input type:keyboard {
          xkb_options caps:escape
      }

      input "1:1:AT_Translated_Set_2_keyboard" {
          xkb_layout us
      }

      input "1739:0:Synaptics_TM3053-003" {
          click_method clickfinger
          dwt enabled
          middle_emulation enabled
          natural_scroll enabled
          scroll_method two_finger
          tap enabled
      }

      ### rules
      for_window [title="Qsynth"] floating enable
      for_window [title=".* — QjackCtl"] floating enable
      for_window [title="Virtual MIDI Piano Keyboard"] floating enable
    '';
  } // (lib.mapAttrs'
    (name: value: lib.nameValuePair "NetworkManager/system-connections/${lib.removePrefix "networks/" name}" { source = value.path; })
    (lib.filterAttrs (name: value: lib.hasPrefix "networks/" name) config.sops.secrets)
  );

  programs.kanshi.profiles = {
    internal = {
      outputs = {
        "eDP-1" = "enable mode 1920x1080 position 0,0 scale 1";
      };
    };

    desk = {
      outputs = {
        "eDP-1" = "enable mode 1920x1080 position 1920,0 scale 1";
        "VIZIO, Inc E390i-A1 0x00000101" = "enable mode 1920x1080 position 0,0 scale 1";
      };
      commands = [
        "${lib.getExe' pkgs.sway "swaymsg"} workspace number 3, move workspace to eDP-1"
        "${lib.getExe' pkgs.sway "swaymsg"} workspace number 1, move workspace to '\"VIZIO, Inc E390i-A1 0x00000101\"'"
      ];
    };

    deskonly = {
      outputs = {
        "eDP-1" = "disable";
        "VIZIO, Inc E390i-A1 0x00000101" = "enable mode 1920x1080 position 0,0 scale 1";
      };
    };
  };

  services.logind.lidSwitch = "ignore";

  services.resolved.dnssec = "false";

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
    };
  };

  home-manager.users.lily = { pkgs, lib, ... }: {
    services.mopidy.extraConfigFiles = [ config.sops.secrets.mopidy-lily-secrets.path ];
  };

  system.stateVersion = "23.11";
}
