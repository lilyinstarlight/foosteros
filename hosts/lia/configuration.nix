{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../config/restic.nix

    ../../config/lily.nix

    ../../config/adb.nix
    ../../config/alien.nix
    ../../config/bluetooth.nix
    ../../config/fcitx5.nix
    ../../config/fwupd.nix
    ../../config/gc.nix
    ../../config/gnupg.nix
    ../../config/homebins.nix
    ../../config/hyfetch.nix
    ../../config/intelgfx.nix
    ../../config/libvirt.nix
    ../../config/lsp.nix
    ../../config/music.nix
    ../../config/networking.nix
    ../../config/nullmailer.nix
    ../../config/pass.nix
    ../../config/pki.nix
    ../../config/podman.nix
    ../../config/sway.nix
    ../../config/udiskie.nix
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
      wireless-networks = {
        restartUnits = [ "supplicant-wlp4s0.service" ];
      };
      wired-networks = {
        restartUnits = [ "supplicant-enp0s25.service" ];
      };
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
    };
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
        ".config/discord"
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
    hostName = "lia";
    domain = "fooster.network";
  };

  networking.supplicant.wlp4s0 = {
    driver = "nl80211";
    extraConf = ''
      p2p_disabled=1
    '';
    configFile.path = config.sops.secrets.wireless-networks.path;
    userControlled.enable = true;
  };
  networking.interfaces.wlp4s0.useDHCP = true;
  systemd.network.networks."40-wlp4s0" = {
    dhcpV4Config = {
      ClientIdentifier = "mac";
      RouteMetric = 600;
    };
    dhcpV6Config = {
      RouteMetric = 600;
    };
  };

  networking.supplicant.enp0s25 = {
    driver = "wired";
    extraConf = ''
      ap_scan=0
    '';
    configFile.path = config.sops.secrets.wired-networks.path;
    userControlled.enable = true;
  };
  networking.interfaces.enp0s25.useDHCP = true;
  systemd.network.networks."40-enp0s25" = {
    dhcpV4Config = {
      ClientIdentifier = "mac";
      RouteMetric = 100;
    };
    dhcpV6Config = {
      RouteMetric = 100;
    };
    linkConfig = {
      RequiredForOnline = "no";
    };
  };

  hardware.bluetooth.settings.General.Name = "Lia";

  hardware.playdate.enable = true;

  services.restic.backups.lia = {
    passwordFile = config.sops.secrets.restic-backup-password.path;
    environmentFile = config.sops.secrets.restic-backup-environment.path;
  };

  systemd.services.restic-backups-lia.serviceConfig.ExecCondition = "${config.systemd.package}/lib/systemd/systemd-networkd-wait-online --interface=enp0s25:routable --timeout=5";

  virtualisation.spiceUSBRedirection.enable = true;

  nix = {
    settings = {
      keep-outputs = true;
      max-jobs = "auto";
    };
  };

  environment.systemPackages = with pkgs; [
    firefox ungoogled-chromium
    pavucontrol
    inkscape gimp-with-plugins krita
    qalculate-gtk
    element-desktop jitsi-meet-electron teams-for-linux
    helvum qjackctl qsynth vmpk calf
    ardour lmms
    sonic-pi sonic-pi-tool open-stage-control
    lilypond
    mpv ffmpeg-full
    freecad prusa-slicer
    hledger
    virt-manager podman-compose
    fq ripgrep-all
    mkusb mkwin
    aria2 openssl wireshark dogdns picocom
    (ansible.overrideAttrs (attrs: {
      propagatedBuildInputs = attrs.propagatedBuildInputs ++ (with python3Packages; [ passlib ]);
    })) azure-cli
    gnumake llvmPackages_latest.clang llvmPackages_latest.lldb
  ] ++ (lib.optionals config.nixpkgs.config.allowUnfree [
    pridecat
    discord slack
  ]);

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
      order += "cpu_temperature 0"
      order += "volume master"
      order += "wireless wlp4s0"
      order += "battery 0"
      order += "disk /"
      order += "tztime local"

      load {
          format = "cpu: %1min"
      }

      cpu_temperature 0 {
          format = "temp: %degrees °C"
      }

      volume master {
          format = "vol: %volume"
          format_muted = "vol: mute"
      }

      wireless wlp4s0 {
          format_up = "wlan: %essid"
          format_down = "wlan: off"
      }

      battery 0 {
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
      order += "cpu_temperature 0"
      order += "battery 0"
      order += "disk /"
      order += "tztime local"

      load {
          format = "cpu: %1min"
      }

      cpu_temperature 0 {
          format = "temp: %degrees °C"
      }

      battery 0 {
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
  };

  programs.kanshi.extraConfig = ''
    profile internal {
      output eDP-1 enable mode 1920x1080 position 0,0 scale 1
    }

    profile desk {
      output eDP-1 enable mode 1920x1080 position 1920,0 scale 1
      output "VIZIO, Inc E390i-A1 0x00000101" enable mode 1920x1080 position 0,0 scale 1
      exec ${pkgs.sway}/bin/swaymsg workspace number 3, move workspace to eDP-1
      exec ${pkgs.sway}/bin/swaymsg workspace number 1, move workspace to '"VIZIO, Inc E390i-A1 0x00000101"'
    }

    profile deskonly {
      output "VIZIO, Inc E390i-A1 0x00000101" enable mode 1920x1080 position 0,0 scale 1
    }
  '';

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
    config = ''
      mailfrom="logs@fooster.network"
      mailto="logs@fooster.network"
      subject="Logs for $(hostname) at $(date +"%F %R")"
    '';
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

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
    };
  };

  programs.swaynag-battery = {
    enable = true;
    powerSupply = "BAT0";
  };

  users = {
    mutableUsers = false;
    users = {
      root.passwordFile = config.sops.secrets.root-password.path;
      lily = {
        passwordFile = config.sops.secrets.lily-password.path;
        extraGroups = with config.users.groups; [ keys.name libvirtd.name adbusers.name ];
      };
    };
  };

  home-manager.users.lily = { pkgs, lib, ... }: {
    services.mopidy.extraConfigFiles = [ config.sops.secrets.mopidy-lily-secrets.path ];

    home.stateVersion = "23.05";
  };

  system.stateVersion = "23.05";
}
