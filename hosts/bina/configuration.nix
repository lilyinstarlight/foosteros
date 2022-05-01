{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../config/restic.nix

    ../../config/alien.nix
    ../../config/pki.nix
    ../../config/lsp.nix
    ../../config/intelgfx.nix
    ../../config/sway.nix
    ../../config/fcitx5.nix
    ../../config/bluetooth.nix
    ../../config/podman.nix
    ../../config/libvirt.nix
    ../../config/adb.nix

    ../../config/lily.nix
  ];

  sops.defaultSopsFile = ./secrets.yaml;
  sops.age.sshKeyPaths = [];
  sops.gnupg.sshKeyPaths = [ "/state/etc/ssh/ssh_host_rsa_key" ];
  sops.secrets = {
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

  environment.persistence."/state" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/var/db/sudo"
      "/var/lib/bluetooth"
      "/var/lib/libvirt"
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
        ".config/Element"
        ".config/discord"
        ".config/obs-studio"
        ".config/pipewire"
        ".config/rncbc.org"
        ".config/teams"
        ".gnupg/crls.d"
        ".gnupg/private-keys-v1.d"
        ".local/share/fish"
        ".local/share/mopidy"
        ".local/share/nvim"
        ".local/share/qutebrowser"
        ".local/state/wireplumber"
        ".mozilla"
        ".password-store"
        ".sonic-pi"
      ];
      files = [
        ".android/adbkey"
        ".android/adbkey.pub"
        ".config/qutebrowser/autoconfig.yml"
        ".config/qutebrowser/quickmarks"
        ".gnupg/pubring.kbx"
        ".gnupg/random_seed"
        ".gnupg/tofu.db"
        ".gnupg/trustdb.gpg"
        ".lmmsrc.xml"
        ".ssh/id_ed25519"
        ".ssh/id_ed25519.pub"
        ".ssh/known_hosts"
      ];
    };
  };

  environment.persistence."/persist" = {
    hideMounts = true;
    users.lily = {
      directories = [
        "iso"
        "tmp"
      ];
    };
  };

  boot = {
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    extraModprobeConfig = ''
      options v4l2loopback video_nr=63
    '';
    kernelModules = [ "v4l2loopback" ];
  };

  networking = {
    hostName = "bina";
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

  systemd.network.networks."80-wl" = {
    name = "wl*";
    DHCP = "yes";

    dhcpV4Config = {
      ClientIdentifier = "mac";
      RouteMetric = 700;
    };
    dhcpV6Config = {
      RouteMetric = 700;
    };
    linkConfig = {
      RequiredForOnline = "no";
    };
    networkConfig = {
      IPv6PrivacyExtensions = "kernel";
    };
  };

  systemd.network.networks."80-en" = {
    name = "en*";
    DHCP = "yes";

    dhcpV4Config = {
      ClientIdentifier = "mac";
      RouteMetric = 200;
    };
    dhcpV6Config = {
      RouteMetric = 200;
    };
    linkConfig = {
      RequiredForOnline = "no";
    };
    networkConfig = {
      IPv6PrivacyExtensions = "kernel";
    };
  };

  hardware.bluetooth.settings = {
    General = {
      Name = "Bina";
    };
  };

  services.restic.backups.bina = {
    passwordFile = config.sops.secrets.restic-backup-password.path;
    environmentFile = config.sops.secrets.restic-backup-environment.path;
  };

  virtualisation.spiceUSBRedirection.enable = true;

  users.users.lily.extraGroups = with config.users.groups; [ keys.name libvirtd.name adbusers.name ];

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
      dates = "weekly";
      persistent = true;
    };
    settings = {
      max-jobs = "auto";
    };
  };

  environment.systemPackages = with pkgs; [
    firefox-wayland ungoogled-chromium
    udiskie
    gnupg pass-wayland-otp
    rofi-pass-wayland rofi-mpd
    pavucontrol
    ncmpcpp beets
    inkscape gimp-with-plugins krita
    mupdf
    element-desktop jitsi-meet-electron
    helvum qjackctl qsynth vmpk calf
    ardour lmms
    sonic-pi sonic-pi-tool open-stage-control
    lilypond
    mpv ffmpeg-full
    retroarchFull
    (wrapOBS {
      plugins = with obs-studio-plugins; [ wlrobs obs-gstreamer obs-move-transition ] ++ (lib.optionals config.nixpkgs.config.allowUnfree [ obs-ndi ]);
    })
    hledger homebank
    virt-manager podman-compose
    ripgrep-all
    mkusb mkwin
    openssl wireshark dogdns picocom
    (ansible.overrideAttrs (attrs: {
      propagatedBuildInputs = attrs.propagatedBuildInputs ++ (with python3Packages; [ passlib ]);
    })) azure-cli
    neofetch
    texlive.combined.scheme-full
    gnumake llvmPackages_latest.clang llvmPackages_latest.bintools llvmPackages_latest.lldb
  ] ++ (lib.optionals config.nixpkgs.config.allowUnfree [
    discord slack teams
  ]);

  environment.etc = {
    "xdg/mimeapps.list".text = ''
      [Default Applications]
      text/html=org.qutebrowser.qutebrowser.desktop
      text/xml=org.qutebrowser.qutebrowser.desktop
      application/xhtml+xml=org.qutebrowser.qutebrowser.desktop
      application/xml=org.qutebrowser.qutebrowser.desktop
      application/rdf+xml=org.qutebrowser.qutebrowser.desktop
      x-scheme-handler/http=org.qutebrowser.qutebrowser.desktop
      x-scheme-handler/https=org.qutebrowser.qutebrowser.desktop
      image/gif=imv.desktop
      image/jpeg=imv.desktop
      image/png=imv.desktop
      image/bmp=imv.desktop
      image/tiff=imv.desktop
      image/heif=imv.desktop
      application/pdf=mupdf.desktop
      application/x-pdf=mupdf.desktop
      application/x-cbz=mupdf.desktop
      application/oxps=mupdf.desktop
      application/vnd.ms-xpsdocument=mupdf.desktop
      application/epub+zip=mupdf.desktop
    '';

    "sway/config.d/bina".text = ''
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

      ### variables
      set $mod mod4
      set $pass ${pkgs.rofi-pass-wayland}/bin/rofi-pass

      ### applications
      bindsym $mod+backslash exec $pass

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

  programs.gnupg.agent.enable = true;

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

  services.pipewire.jack.enable = true;

  services.dnsimple-ddns = {
    enable = true;
    configFile = config.sops.secrets.dnsimple-ddns.path;
  };

  services.nullmailer = {
    enable = true;
    config = {
      me = config.networking.hostName;
      defaultdomain = "fooster.network";
      allmailfrom = "logs@fooster.network";
      adminaddr = "logs@fooster.network";
    };
    remotesFile = config.sops.secrets.nullmailer-remotes.path;
  };
  systemd.services.nullmailer.serviceConfig = {
    SupplementaryGroups = [ config.users.groups.keys.name ];
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
      systemd-udevd\[[0-9]*\]: /nix/store/[0-9a-z]\{32\}-systemd-[^/]*/lib/udev/rules\.d/50-udev-default\.rules:42 Unknown group 'sgx', ignoring
      kernel: Bluetooth: hci0: unexpected event for opcode 0xfc2f
      bluetoothd\[[0-9]*\]: profiles/sap/server\.c:sap_server_register() Sap driver initialization failed\.
      bluetoothd\[[0-9]*\]: sap-server: Operation not permitted (1)
      pipewire\[[0-9]*\]: jack-device 0x[0-9a-f]\{12\}: can't open client: Input/output error
    '';
  };

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
    };
  };

  services.swaynag-battery = {
    enable = true;
    powerSupply = "BAT0";
  };

  users.mutableUsers = false;
  users.users.root.passwordFile = config.sops.secrets.root-password.path;
  users.users.lily.passwordFile = config.sops.secrets.lily-password.path;

  home-manager.users.lily = { pkgs, lib, ... }: let cfg = config.home-manager.users.lily; in {
    services.mopidy = {
      enable = true;
      settings = {
        file.enabled = false;
        local.media_dir = "${cfg.home.homeDirectory}/music";
      };
      extensionPackages = with pkgs; [
        mopidy-local mopidy-iris mopidy-mpd
      ] ++ (lib.optionals config.nixpkgs.config.allowUnfree [ mopidy-spotify ]);
      extraConfigFiles = [
        config.sops.secrets.mopidy-lily-secrets.path
      ];
    };

    services.mpdris2 = {
      enable = true;
      notifications = true;
      multimediaKeys = false;
      cdPrevious = true;
      mpd = {
        musicDirectory = cfg.services.mopidy.settings.local.media_dir;
        service = "mopidy.service";
      };
    };

    services.udiskie = {
      enable = true;
      automount = false;
      tray = "never";
    };

    systemd.user.services.mpdris2 = {
      # wait for mako since mpdris2 disables notifications if the org.freedesktop.Notifications busname is not available yet
      Unit.After = [ "mako.service" ];
      # wait for mpd port to become available to avoid reconnected notification on bootup
      Service.ExecStartPre = "${pkgs.coreutils}/bin/timeout 60 ${pkgs.bash}/bin/sh -c 'while ! ${pkgs.iproute2}/sbin/ss -tlnH sport = :6600 | ${pkgs.gnugrep}/bin/grep -q \"^LISTEN.*:6600\"; do ${pkgs.coreutils}/bin/sleep 1; done'";
    };

    programs.beets = {
      enable = true;
      settings = {
        directory = cfg.services.mopidy.settings.local.media_dir;
      };
    };

    xdg.configFile = {
      "rofi-pass/config".text = ''
        typePassOrOtp () {
          checkIfPass

          case "$password" in
            'otpauth://'*)
              typed="OTP token"
              printf '%s' "$(generateOTP)" | wtype -
              ;;

            *)
              typed="password"
              printf '%s' "$password" | wtype -
              ;;
          esac

          if [[ $notify == "true" ]]; then
              if [[ "''${stuff[notify]}" == "false" ]]; then
                  :
              else
                  notify-send "rofi-pass" "finished typing $typed";
              fi
          elif [[ $notify == "false" ]]; then
              if [[ "''${stuff[notify]}" == "true" ]]; then
                  notify-send "rofi-pass" "finished typing $typed";
              else
                  :
              fi
          fi

          clearUp
        }

        default_do=typePassOrOtp
        clip=clipboard
      '';

      "petty/pettyrc".text = ''
        shell=${pkgs.fish}/bin/fish
        session1=sway
      '';

      "sessions/sway".source = pkgs.writeScript "sway" ''
        #!/bin/sh
        export NIXOS_OZONE_WL=1
        exec /etc/sessions/sway
      '';
    };

    home.file = {
      "bin/addr" = {
        text = ''
          #!/bin/sh
          exec curl "$@" icanhazip.com
        '';
        executable = true;
      };

      "bin/alert" = {
        text = ''
          #!/bin/sh
          exec curl -s -X POST -d body="$*" https://alert.lily.flowers/ >/dev/null
        '';
        executable = true;
      };

      "bin/genpass" = {
        text = ''
          #!/bin/sh
          grep -E '^\w{4,}$' ${pkgs.google-10000-english}/share/dict/google-10000-english-usa-no-swears.txt | sort -R | head -n4 | paste -sd ""
        '';
        executable = true;
      };

      "bin/neofetch" = {
        text = ''
          #!/bin/sh
          case "$SHELL" in
            */petty)
              . "$HOME"/.config/petty/pettyrc
              export SHELL="$shell"
              ;;
          esac

          exec /run/current-system/sw/bin/neofetch --colors 5 4 4 5 4 7 --ascii_distro nixos --ascii_colors 5 4 --separator ' ->' "$@"
        '';
        executable = true;
      };

      "bin/pdflatexmk" = {
        text = ''
          #!/bin/sh
          latexmk -pdf "$@" && latexmk -c "$@"
        '';
        executable = true;
      };

      "bin/ssh" = {
        text = ''
          #!/bin/sh
          if [ "$TERM" = alacritty ]; then
            export TERM=xterm-256color
          fi
          exec "$(which --skip-tilde ssh)" "$@"
        '';
        executable = true;
      };

      "bin/scp-nofp" = {
        text = ''
          #!/bin/sh
          scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$@"
        '';
        executable = true;
      };

      "bin/sftp-nofp" = {
        text = ''
          #!/bin/sh
          sftp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$@"
        '';
        executable = true;
      };

      "bin/ssh-nofp" = {
        text = ''
          #!/bin/sh
          ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$@"
        '';
        executable = true;
      };

      "bin/wf-loopback" = {
        text = ''
          #!/bin/sh
          exec wf-recorder --muxer=v4l2 --codec=rawvideo --pixel-format=yuv420p --file=/dev/video63 "$@"
        '';
        executable = true;
      };
    };

    home.activation = {
      linkHomeMnt = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD ln -sTf $VERBOSE_ARG /run/media/"$USER" "$HOME"/mnt
      '';
    };
  };

  system.stateVersion = "21.05";
}
