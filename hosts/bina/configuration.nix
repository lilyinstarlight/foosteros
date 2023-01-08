{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../config/restic.nix

    ../../config/lily.nix

    ../../config/adb.nix
    ../../config/alien.nix
    ../../config/azure.nix
    ../../config/bluetooth.nix
    ../../config/cad.nix
    ../../config/fcitx5.nix
    ../../config/fwupd.nix
    ../../config/gc.nix
    ../../config/gnupg.nix
    ../../config/hibernate.nix
    ../../config/homebins.nix
    ../../config/hyfetch.nix
    ../../config/intelgfx.nix
    ../../config/ledger.nix
    ../../config/libvirt.nix
    ../../config/lsp.nix
    ../../config/miracast.nix
    ../../config/music.nix
    ../../config/networkmanager.nix
    ../../config/nullmailer.nix
    ../../config/pass.nix
    ../../config/pki.nix
    ../../config/playdate.nix
    ../../config/podman.nix
    ../../config/production.nix
    ../../config/sway.nix
    ../../config/sysrq.nix
    ../../config/tex.nix
    ../../config/udiskie.nix
    ../../config/workstation.nix
  ];

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
        restartUnits = [ "mopidy.service" ];
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
      "/var/lib/fprint"
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
        ".config/discordptb"
        ".config/Element"
        ".config/obs-studio"
        ".config/pipewire"
        ".config/PrusaSlicer"
        ".config/qutebrowser"
        ".config/rncbc.org"
        ".config/teams-for-linux"
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
    hostName = "bina";
    domain = "fooster.network";
  };

  hardware.bluetooth.settings.General.Name = "Bina";

  hardware.video.hidpi.enable = true;

  services.restic.backups.bina = {
    passwordFile = config.sops.secrets.restic-backup-password.path;
    environmentFile = config.sops.secrets.restic-backup-environment.path;
  };

  systemd.services.restic-backups-bina.serviceConfig.ExecCondition = "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --interface=enp0s13f0u2c2:routable --timeout=5";

  virtualisation.spiceUSBRedirection.enable = true;

  nix = {
    settings = {
      keep-outputs = true;
      max-jobs = "auto";
    };
  };

  environment.etc = {
    "sway/config.d/bina".text = ''
      ### ouputs
      output eDP-1 resolution 2256x1504 position 0,0 scale 1.5

      ### inputs
      input type:keyboard {
          xkb_options caps:escape
      }

      input "1:1:AT_Translated_Set_2_keyboard" {
          xkb_layout us
      }

      input "2362:628:PIXA3854:00_093A:0274_Touchpad" {
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

    "xdg/i3status/config".text = ''
      general {
          colors = true

          color_good = "#dadada"
          color_degraded = "#aa4444"
          color_bad = "#aa4444"

          interval = 1

          output_format = "i3bar"
      }

      order += "load"
      order += "cpu_temperature 7"
      order += "volume master"
      order += "wireless wlp166s0"
      order += "battery 1"
      order += "disk /"
      order += "tztime local"

      load {
          format = "cpu: %1min"
      }

      cpu_temperature 7 {
          format = "temp: %degrees °C"
      }

      volume master {
          format = "vol: %volume"
          format_muted = "vol: mute"
      }

      wireless wlp166s0 {
          format_up = "wlan: %essid"
          format_down = "wlan: off"
      }

      battery 1 {
          integer_battery_capacity = true
          last_full_capacity = true
          low_threshold = 12

          status_chr = "^"
          status_bat = ""
          status_unk = "?"
          status_full = ""

          format = "batt: %status%percentage"
          format_down = "batt: none"
      }

      disk / {
          format = "disk: %avail"
      }

      tztime local {
          format = "%H:%M"
      }
    '';

    "xdg/i3status/tmux".text = ''
      general {
          colors = true

          color_good = "#dadada"
          color_degraded = "#aa4444"
          color_bad = "#aa4444"

          interval = 1

          output_format = "none"
          separator = " • "
      }

      order += "load"
      order += "cpu_temperature 7"
      order += "battery 1"
      order += "disk /"
      order += "tztime local"

      load {
          format = "cpu: %1min"
      }

      cpu_temperature 7 {
          format = "temp: %degrees °C"
      }

      battery 1 {
          integer_battery_capacity = true
          last_full_capacity = true
          low_threshold = 12

          status_chr = "^"
          status_bat = ""
          status_unk = "?"
          status_full = ""

          format = "batt: %status%percentage"
          format_down = "batt: none"
      }

      disk / {
          format = "disk: %avail"
      }

      tztime local {
          format = "%H:%M"
      }
    '';
  } // (lib.mapAttrs'
    (name: value: lib.nameValuePair "NetworkManager/system-connections/${lib.removePrefix "networks/" name}" { source = value.path; })
    (lib.filterAttrs (name: value: lib.hasPrefix "networks/" name) config.sops.secrets)
  );


  programs.kanshi.extraConfig = ''
    profile internal {
      output eDP-1 enable mode 2256x1504 position 0,0 scale 1.5
    }

    profile desk {
      output eDP-1 enable mode 2256x1504 position 1920,0 scale 1.5
      output "VIZIO, Inc E390i-A1 0x00000101" enable mode 1920x1080 position 0,0 scale 1
      exec ${pkgs.sway}/bin/swaymsg workspace number 3, move workspace to eDP-1
      exec ${pkgs.sway}/bin/swaymsg workspace number 1, move workspace to '"VIZIO, Inc E390i-A1 0x00000101"'
    }

    profile deskonly {
      output "VIZIO, Inc E390i-A1 0x00000101" enable mode 1920x1080 position 0,0 scale 1
    }
  '';

  services.resolved.dnssec = "false";

  services.fprintd.enable = true;

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
    config = ''
      mailfrom="logs@fooster.network"
      mailto="logs@fooster.network"
      subject="Logs for $(hostname) at $(date +"%F %R")"
    '';
    filter = ''
      Failed to adjust quota for subvolume "/srv": Bad file descriptor
      Failed to adjust quota for subvolume "/var/lib/portables": Bad file descriptor
      Failed to adjust quota for subvolume "/var/lib/machines": Bad file descriptor
      bluetoothd\[[0-9]*\]: src/plugin\.c:plugin_init() Failed to init vcp plugin
      bluetoothd\[[0-9]*\]: src/plugin\.c:plugin_init() Failed to init mcp plugin
      bluetoothd\[[0-9]*\]: src/plugin\.c:plugin_init() Failed to init bap plugin
      bluetoothd\[[0-9]*\]: profiles/sap/server\.c:sap_server_register() Sap driver initialization failed\.
      bluetoothd\[[0-9]*\]: sap-server: Operation not permitted (1)
      bluetoothd\[[0-9]*\]: src/profile\.c:record_cb() Unable to get Hands-Free Voice gateway SDP record: Host is down
      kernel: tpm tpm0: \[Firmware Bug\]: TPM interrupt not working, polling instead
      kernel: cros-usbpd-charger cros-usbpd-charger\.2\.auto: Unexpected number of charge port count
      kernel: cros_ec_lpcs cros_ec_lpcs\.0: bad packet checksum [0-9a-f]\{2\}
      systemd-udevd\[[0-9]*\]: /nix/store/[0-9a-z]\{32\}-systemd-[^/]*/lib/udev/rules\.d/50-udev-default\.rules:[0-9]* Unknown group '[^']*', ignoring
      dbus-broker-launch\[[0-9]*\]: Ignoring duplicate name '[^']*' in service file '[^']*'
    '';
  };

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
    };
  };

  programs.swaynag-battery = {
    enable = true;
    powerSupply = "BAT1";
  };

  users = {
    mutableUsers = false;
    users = {
      root.passwordFile = config.sops.secrets.root-password.path;
      lily = {
        passwordFile = config.sops.secrets.lily-password.path;
        extraGroups = with config.users.groups; map (grp: grp.name) [ networkmanager libvirtd keys adbusers ];
      };
    };
  };

  home-manager.users.lily = { pkgs, lib, ... }: {
    services.mopidy.extraConfigFiles = [ config.sops.secrets.mopidy-lily-secrets.path ];

    home.stateVersion = "23.05";
  };

  system.stateVersion = "23.05";
}
