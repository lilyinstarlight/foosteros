{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../config/base.nix
    ../../config/sway.nix

    ../../config/lily.nix
  ];

  networking.hostName = "bina";
  networking.domain = "fooster.network";

  # networking.wireless.enable = true;
  networking.interfaces.ens33.useDHCP = true;

  environment.systemPackages = with pkgs; [
    gnupg pass-wayland
    vimpc
    sonic-pi sonic-pi-tool
  ];

  environment.etc."sway/config.d/bina".text = ''
    ### ouputs
    #output eDP-1 resolution 2880x1800 position 0 0 scale 2
    output Virtual-1 resolution 2560x1600 position 0 0 scale 2

    ### inputs
    #input "1739:1751:Apple_SPI_Touchpad" {
    #    click_method clickfinger
    #    dwt enabled
    #    middle_emulation enabled
    #    natural_scroll enabled
    #    scroll_method two_finger
    #    tap enabled
    #    pointer_accel 0.8
    #}
    #
    #input "76:617:FoosterMOUSE_Mouse" {
    #    natural_scroll enabled
    #    scroll_button 273
    #    scroll_method on_button_down
    #}
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
    order += "volume master"
    order += "battery 1"
    order += "disk /"
    order += "tztime local"

    load {
        format = "cpu: %1min"
    }

    volume master {
        format = "vol: %volume"
        format_muted = "vol: mute"
    }

    battery 1 {
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
    order += "battery 1"
    order += "disk /"
    order += "tztime local"

    load {
        format = "cpu: %1min"
    }

    battery 1 {
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

  #environment.etc."xdg/i3status/config".text = ''
  #  general {
  #      colors = true

  #      color_good = "#dadada"
  #      color_degraded = "#aa4444"
  #      color_bad = "#aa4444"

  #      interval = 1
  #
  #      output_format = "i3bar"
  #  }

  #  order += "load"
  #  order += "cpu_temperature 0"
  #  order += "volume master"
  #  order += "wireless wlp3s0"
  #  order += "battery 0"
  #  order += "disk /"
  #  order += "tztime local"

  #  load {
  #      format = "cpu: %1min"
  #  }

  #  cpu_temperature 0 {
  #      format = "temp: %degrees °C"
  #  }

  #  volume master {
  #      format = "vol: %volume"
  #      format_muted = "vol: mute"
  #  }

  #  wireless wlp3s0 {
  #      format_up = "wlan: %essid"
  #      format_down = "wlan: off"
  #  }

  #  battery 0 {
  #      integer_battery_capacity = true
  #      low_threshold = 12

  #      status_chr = "^"
  #      status_bat = ""
  #      status_unk = "?"
  #      status_full = ""

  #      format = "batt: %status%percentage"
  #      format_down = "batt: none"
  #  }

  #  disk / {
  #      format = "disk: %avail"
  #  }

  #  tztime local {
  #      format = "%H:%M"
  #  }
  #'';

  #environment.etc."xdg/i3status/tmux".text = ''
  #  general {
  #      colors = true

  #      color_good = "#dadada"
  #      color_degraded = "#aa4444"
  #      color_bad = "#aa4444"

  #      interval = 1

  #      output_format = "none"
  #      separator = " • "
  #  }

  #  order += "load"
  #  order += "cpu_temperature 0"
  #  order += "battery 0"
  #  order += "disk /"
  #  order += "tztime local"

  #  load {
  #      format = "cpu: %1min"
  #  }

  #  cpu_temperature 0 {
  #      format = "temp: %degrees °C"
  #  }

  #  battery 0 {
  #      integer_battery_capacity = true
  #      low_threshold = 12

  #      status_chr = "^"
  #      status_bat = ""
  #      status_unk = "?"
  #      status_full = ""

  #      format = "batt: %status%percentage"
  #      format_down = "batt: none"
  #  }

  #  disk / {
  #      format = "disk: %avail"
  #  }

  #  tztime local {
  #      format = "%H:%M"
  #  }
  #'';

  programs.gnupg.agent.enable = true;

  # services.printing.enable = true;

  services.xserver = {
    # xkbModel = "apple_laptop";
    # xkbVariant = "mac";
  };

  services.nullmailer = {
    enable = true;
    config = {
      me = config.networking.hostName;
      defaultdomain = "fooster.network";
      allmailfrom = "lily@fooster.network";
      adminaddr = "logs@fooster.network";
    };
    # remotesFile = "/etc/nixos/secrets/nullmailer-remotes";
  };

  # services.tlp.enable = true;

  services.swaynag-battery = {
    enable = true;
    powerSupply = "BAT1";
  };

  services.mopidy-user = {
    enable = true;
    extensionPackages = with pkgs; [
      mopidy-spotify mopidy-iris mopidy-mpd
    ];
    extraConfigFiles = [
      "$HOME/.config/mopidy/mopidy.conf"
    ];
  };

  virtualisation.vmware.guest.enable = true;

  system.stateVersion = "21.03";
}
