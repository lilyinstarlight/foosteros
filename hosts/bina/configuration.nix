{ config, lib, pkgs, ... }:

{
  imports = [
    <sops-nix/modules/sops>

    ./hardware-configuration.nix

    ../../config/base.nix
    ../../config/sway.nix

    ../../config/lily.nix
  ];

  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets = {
    wpa-supplicant-networks = {};
    nullmailer-remotes = {
      mode = "0440";
      group = config.services.nullmailer.group;
    };
  };

  systemd.services.wireless-networks = {
    wantedBy = [ "multi-user.target" ];
    after = [ "wpa_supplicant.service" ];
    requires = [ "wpa_supplicant.service" ];

    description = "Load Wireless Network Definitions";

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
    };

    script = ''
      for i in $(seq 1 10); do
        if ! [ -d /var/run/wpa_supplicant ]; then
          sleep 1
        fi
      done
      if ! [ -d /var/run/wpa_supplicant ]; then
        exit 1
      fi

      iface="$(ls /var/run/wpa_supplicant | head -n1)"

      for iface in $(ls /var/run/wpa_supplicant); do
        grep -v '^[ \t]*$\|^[ \t]*#' ${config.sops.secrets.wpa-supplicant-networks.path} | xargs -L 1 ${pkgs.wpa_supplicant}/bin/wpa_cli -i "$iface"
      done
    '';
  };

  networking.hostName = "bina";
  networking.domain = "fooster.network";

  networking.wireless = {
    enable = true;
    extraConfig = ''
      p2p_disabled=1
    '';
    userControlled.enable = true;
  };
  networking.interfaces.enp0s25.useDHCP = true;
  networking.interfaces.wlp4s0.useDHCP = true;

  systemd.network.networks."40-enp0s25".linkConfig = {
    RequiredForOnline = "no";
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    package = pkgs.bluezFull;
  };
  hardware.pulseaudio.package = pkgs.pulseaudioFull;

  virtualisation.kvmgt.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemuPackage = pkgs.qemu_kvm;
  };
  virtualisation.podman.enable = true;

  users.users.lily.extraGroups = [ "libvirtd" ];

  environment.systemPackages = with pkgs; [
    gnupg pass-wayland pass-otp
    wofi-pass
    mpc_cli vimpc beets
    inkscape glimpse-with-plugins krita
    mupdf
    element-desktop discord
    sonic-pi sonic-pi-tool
    homebank
    virt-manager podman-compose
  ];

  environment.etc."sway/config.d/bina".text = ''
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
    set $pass ${pkgs.wofi-pass}/bin/wofi-pass -s

    ### buttons
    bindsym xf86audioplay exec ${pkgs.mpc_cli}/bin/mpc -q toggle
    bindsym xf86audiostop exec ${pkgs.mpc_cli}/bin/mpc -q stop
    bindsym xf86audioprev exec ${pkgs.mpc_cli}/bin/mpc -q prev
    bindsym xf86audionext exec ${pkgs.mpc_cli}/bin/mpc -q next

    ### applications
    bindsym $mod+backslash exec $pass
  '';

  environment.etc."xdg/i3status/config".text = ''
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

  environment.etc."xdg/i3status/tmux".text = ''
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

  programs.gnupg.agent.enable = true;

  # services.printing.enable = true;

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

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    };
  };

  services.swaynag-battery = {
    enable = true;
    powerSupply = "BAT0";
  };

  services.mopidy-user = {
    enable = true;
    extensionPackages = with pkgs; [
      mopidy-spotify mopidy-iris mopidy-mpd
    ];
    extraConfigFiles = [
      "$XDG_CONFIG_DIR/mopidy/mopidy.conf"
    ];
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

  system.stateVersion = "21.05";
}
