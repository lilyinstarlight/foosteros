{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../config/base.nix
    ../../config/sway.nix
    ../../config/fcitx5.nix

    ../../config/lily.nix
  ];

  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets = {
    wireless-networks = {};
    wired-networks = {};
    nullmailer-remotes = {
      mode = "0440";
      group = config.services.nullmailer.group;
    };
    mopidy-lily-secrets = {
      mode = "0400";
      owner = config.users.users.lily.name;
      group = config.users.users.lily.group;
    };
  };

  networking.hostName = "bina";
  networking.domain = "fooster.network";

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

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    package = pkgs.bluezFull;
    settings = {
      General = {
        Name = "Bina";
      };
    };
  };

  hardware.opengl.extraPackages = with pkgs; [
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
    intel-media-driver
  ];

  virtualisation.kvmgt.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemuPackage = pkgs.qemu_kvm;
  };
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.podman.enable = true;

  users.users.lily.extraGroups = [ config.users.groups.keys.name "libvirtd" ];

  environment.systemPackages = with pkgs; [
    gnupg pass-wayland-otp
    rofi-pass-wayland rofi-mpd
    pavucontrol
    mpc_cli ncmpcpp beets
    inkscape gimp-with-plugins krita
    mupdf
    element-desktop jitsi-meet-electron
    helvum qjackctl qsynth vmpk calf
    ardour lmms
    sonic-pi sonic-pi-tool open-stage-control
    lilypond
    mpv ffmpeg-full
    (wrapOBS {
      plugins = with obs-studio-plugins; [ wlrobs obs-gstreamer obs-move-transition ] ++ (lib.optionals config.nixpkgs.config.allowUnfree [ obs-ndi ]);
    })
    homebank
    virt-manager podman-compose
    mkusb mkwin
  ] ++ (lib.optionals config.nixpkgs.config.allowUnfree [
    discord teams
  ]);

  environment.etc = {
    "xdg/mimeapps.list".text = ''
      [Default Applications]
      text/html=org.qutebrowser.qutebrowser.desktop
      text/xml=org.qutebrowser.qutebrowser.desktop
      application/xhtml+xml=org.qutebrowser.qutebrowser.desktop
      application/xml=org.qutebrowser.qutebrowser.desktop
      application/rdf+xml=org.qutebrowser.qutebrowser.desktop
      image/gif=org.qutebrowser.qutebrowser.desktop
      image/jpeg=org.qutebrowser.qutebrowser.desktop
      image/png=org.qutebrowser.qutebrowser.desktop
      x-scheme-handler/http=org.qutebrowser.qutebrowser.desktop
      x-scheme-handler/https=org.qutebrowser.qutebrowser.desktop
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

      ### buttons
      bindsym xf86audioplay exec ${pkgs.mpc_cli}/bin/mpc -q toggle
      bindsym xf86audiostop exec ${pkgs.mpc_cli}/bin/mpc -q stop
      bindsym xf86audioprev exec ${pkgs.mpc_cli}/bin/mpc -q prev
      bindsym xf86audionext exec ${pkgs.mpc_cli}/bin/mpc -q next

      ### applications
      bindsym $mod+backslash exec $pass

      ### rules
      for_window [title="Qsynth"] floating enable
      for_window [title=".* — QjackCtl"] floating enable
      for_window [title="Virtual MIDI Piano Keyboard"] floating enable

      ### desktop services
      exec_always ${config.i18n.inputMethod.package}/bin/fcitx5 -dr
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

  services.resolved.dnssec = "false";

  services.pipewire.jack.enable = true;

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

  services.tlp.enable = true;

  services.swaynag-battery = {
    enable = true;
    powerSupply = "BAT0";
  };

  security.pki.certificates = [
    ''
      -----BEGIN CERTIFICATE-----
      MIIElzCCAv+gAwIBAgIBATANBgkqhkiG9w0BAQsFADA6MRgwFgYDVQQKDA9GT09T
      VEVSLk5FVFdPUksxHjAcBgNVBAMMFUNlcnRpZmljYXRlIEF1dGhvcml0eTAeFw0y
      MDA3MzExNjUxMjNaFw00MDA3MzExNjUxMjNaMDoxGDAWBgNVBAoMD0ZPT1NURVIu
      TkVUV09SSzEeMBwGA1UEAwwVQ2VydGlmaWNhdGUgQXV0aG9yaXR5MIIBojANBgkq
      hkiG9w0BAQEFAAOCAY8AMIIBigKCAYEA44Twlu/kugD/99g6Oal69sj44xjjXTlk
      kTbAaNo1KpCmtwmlfvoUQ9A/GPN7r0bAxRYgg4lf0URzP9Ejj8rhc6ufKZp9cNIJ
      IyMllHYsm4n1VpFqq+OnU53bR1r/cfc3u1af+6DBqHVEniylRFCXpP548mN63fG2
      cMxqzCeNpzAcGhVJwt0xINLsKJldbqbg0Ay3OuRzzOqyIN90tuDvnjNS2rUsmekm
      7roxPNdE8Wjd6F7XNzxLqjlBuoKKGSa3sPE+gKXbMFoqegUI2kJExUxJdyvbTw4l
      bHmu9wlfGQsLb1qr3hl0qVzbbpSJUJ/75hQsbZ81Ennl1GNUMEKz+NXqaUkd2gqZ
      GOWtiiFsbzYte5LqZ5//LKpOfV3AEpStDhmSIOOY/Z7W6bpd6mxARFrHbnEfpDPb
      sd2E13+A90R3Q7FAr5RElWAsd1ezmGgRQn75tIq226vnxqtVCA3zDoFDuuFh0NA/
      iPqZuBs9kgN08m/qW8y+Xd0mWjfpqtjdAgMBAAGjgacwgaQwHwYDVR0jBBgwFoAU
      2lDSbYOdzwWLGe8eCpUhOlcCpOIwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8E
      BAMCAcYwHQYDVR0OBBYEFNpQ0m2Dnc8FixnvHgqVITpXAqTiMEEGCCsGAQUFBwEB
      BDUwMzAxBggrBgEFBQcwAYYlaHR0cDovL2lwYS1jYS5mb29zdGVyLm5ldHdvcmsv
      Y2Evb2NzcDANBgkqhkiG9w0BAQsFAAOCAYEAcbLRAckeh8EpDAuZXbqu6hsYO7+y
      A6Odu4fUTvfst/lrDyG0r8o+7Y7Un0bPFXlMenayeq20B8laCi68mXS/da2p7Ajx
      LVnQo6xV8g5Mkc6YZ0erS6jU0eFVoXuV1ZqCiLAiY4beZvq6OtTdoXsxykzhj5vH
      xIS/KkSy46PK7DiaaL+2iYVX8uoPOwr90IcbJG+ZyKDxS16nAvKtBYnazigUjNsx
      txXNkYVb++kVhCpZQbcdB1rGZTphCNFqR1gKXo5fv+OlyywQxvlR46g6dr4qCi+D
      Co+yMFgc3tkTxg3imeH8vo9EWTaJugIRbqbkWvqKBLXqowHDjSMQf/8J4W/oJawk
      LvurI17UfPDTR9b0YpwNkIWfEfes80ngdjDLstEwh+nPtppMFHO8z0W2IgY72iaQ
      25dAhsdlIfpGxGha7Z4r3TFh/xpxdGUJAU8o2NnirVPhwFNdCsTtskgbbIWo/pfk
      WHSTeNkgtTUWb3IYwqSMq8SITttXp/ig3Ibr
      -----END CERTIFICATE-----
    ''
  ];

  users.users.lily.shell = pkgs.petty;

  home-manager.users.lily = let cfg = config.home-manager.users.lily; in {
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

    systemd.user.services.mpdris2.Unit.After = [ "mako.service" ];

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

      "bin/monitor-both" = {
        text = ''
          #!/bin/sh
          swaymsg output eDP-1 enable resolution 1920x1080 position 1920 0 scale 1
          swaymsg output DP-1 enable resolution 1920x1080 position 0 0 scale 1
        '';
        executable = true;
      };

      "bin/monitor-external" = {
        text = ''
          #!/bin/sh
          swaymsg output eDP-1 disable
          swaymsg output DP-1 enable resolution 1920x1080 position 0 0 scale 1
        '';
        executable = true;
      };

      "bin/monitor-internal" = {
        text = ''
          #!/bin/sh
          swaymsg output eDP-1 enable resolution 1920x1080 position 0 0 scale 1
          swaymsg output DP-1 disable
        '';
        executable = true;
      };

      "bin/neofetch" = {
        text = ''
          #!/bin/sh
          case "$SHELL" in */petty)
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
    };
  };

  system.stateVersion = "21.05";
}
