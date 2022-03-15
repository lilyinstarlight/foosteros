{ config, lib, pkgs, ... }:

let
  sway-dconf-settings = pkgs.writeTextFile {
    name = "sway-dconf-settings";
    destination = "/dconf/sway-custom";
    text = ''
      [org/gnome/desktop/interface]
      gtk-theme='Materia-Fooster'
      icon-theme='Papirus-Dark'
      cursor-theme='Bibata-Modern-Classic'

      [org/gnome/desktop/wm/preferences]
      theme='Materia-Fooster'
    '';
  };

  sway-dconf-db = pkgs.runCommand "sway-dconf-db" { preferLocalBuild = true; } ''
    ${pkgs.dconf}/bin/dconf compile $out ${sway-dconf-settings}/dconf
  '';

  sway-dconf-profile = pkgs.writeText "sway-dconf-profile" ''
    user-db:user
    file-db:${sway-dconf-db}
  '';
in

{
  imports = [
    ./fonts.nix
    ./petty.nix
    ./pipewire.nix
  ];

  home-manager.sharedModules = [
    ({ config, lib, pkgs, ... }: {
      programs.qutebrowser = {
        enable = true;
        loadAutoconfig = true;
        settings = {
          colors.webpage.preferred_color_scheme = "dark";
          content.pdfjs = true;
          downloads.location.prompt = false;
          editor.command = ["${pkgs.alacritty}/bin/alacritty" "-e" "vi" "{}"];
          fonts = {
            default_family = "Monofur Nerd Font";
            default_size = "12pt";
          };
          tabs = {
            last_close = "close";
            title.format = "{audio}{current_title}";
          };
          window.title_format = "{perc}{private}{current_title}";
        };
      };

      programs.rofi = {
        enable = true;
        package = pkgs.rofi-wayland;
        terminal = "${pkgs.alacritty}/bin/alacritty";
        theme = let
          inherit (config.lib.formats.rasi) mkLiteral;
        in {
          "*" = {
            darkbackground = mkLiteral "#111111";
            background = mkLiteral "#333333";
            altbackground = mkLiteral "#222222";
            foreground = mkLiteral "#f29bd4";
            grayforeground = mkLiteral "#888888";
            spacing = 2;
            background-color = mkLiteral "var(darkbackground)";
            border-color = mkLiteral "var(foreground)";
          };
          "element" = {
            padding = mkLiteral "1px";
            spacing = mkLiteral "5px";
            border = 0;
            cursor = mkLiteral "pointer";
          };
          "element normal.normal" = {
              background-color = mkLiteral "var(background)";
              text-color = mkLiteral "var(foreground)";
          };
          "element normal.urgent" = {
              background-color = mkLiteral "var(background)";
              text-color = mkLiteral "var(foreground)";
          };
          "element normal.active" = {
              background-color = mkLiteral "var(background)";
              text-color = mkLiteral "var(foreground)";
          };
          "element alternate.normal" = {
              background-color = mkLiteral "var(altbackground)";
              text-color = mkLiteral "var(foreground)";
          };
          "element alternate.urgent" = {
              background-color = mkLiteral "var(altbackground)";
              text-color = mkLiteral "var(foreground)";
          };
          "element alternate.active" = {
              background-color = mkLiteral "var(altbackground)";
              text-color = mkLiteral "var(foreground)";
          };
          "element selected.normal" = {
              background-color = mkLiteral "var(foreground)";
              text-color = mkLiteral "var(background)";
          };
          "element selected.urgent" = {
              background-color = mkLiteral "var(foreground)";
              text-color = mkLiteral "var(background)";
          };
          "element selected.active" = {
              background-color = mkLiteral "var(foreground)";
              text-color = mkLiteral "var(background)";
          };
          "element-text" = {
            background-color = mkLiteral "rgba(0, 0, 0, 0%)";
            text-color = mkLiteral "inherit";
            highlight = mkLiteral "inherit";
            cursor = mkLiteral "inherit";
          };
          "element-icon" = {
            background-color = mkLiteral "rgba(0, 0, 0, 0%)";
            size = mkLiteral "1em";
            text-color = mkLiteral "inherit";
            cursor = mkLiteral "inherit";
          };
          "window" = {
            padding = 5;
            border = 1;
          };
          "mainbox" = {
            padding = 0;
            border = 0;
          };
          "message" = {
            padding = mkLiteral "1px";
            border-color = mkLiteral "var(background)";
            border = 0;
          };
          "textbox" = {
            text-color = mkLiteral "var(foreground)";
          };
          "listview" = {
            padding = mkLiteral "2px 0px 0px";
            scrollbar = true;
            spacing = mkLiteral "2px";
            fixed-height = 0;
            border-color = mkLiteral "var(background)";
            border = 0;
          };
          "scrollbar" = {
            width = "4px";
            padding = 0;
            handle-width = "8px";
            border = 0;
            handle-color = mkLiteral "var(foreground)";
          };
          "sidebar" = {
            border-color = mkLiteral "var(background)";
            border = 0;
          };
          "button" = {
            spacing = 0;
            text-color = mkLiteral "var(foreground)";
            cursor = mkLiteral "pointer";
          };
          "button selected" = {
            background-color = mkLiteral "var(foreground)";
            text-color = mkLiteral "var(background)";
          };
          "num-filtered-rows, num-rows" = {
            text-color = mkLiteral "var(grayforeground)";
            expand = false;
          };
          "textbox-num-sep" = {
            text-color = mkLiteral "var(grayforeground)";
            expand = false;
            str = "/";
          };
          "inputbar" = {
            padding = mkLiteral "1px";
            spacing = 0;
            text-color = mkLiteral "var(foreground)";
            children = mkLiteral "[prompt, textbox-prompt-colon, entry, num-filtered-rows, textbox-num-sep, num-rows, case-indicator]";
          };
          "case-indicator" = {
            spacing = 0;
            text-color = mkLiteral "var(foreground)";
          };
          "entry" = {
            spacing = 0;
            text-color = mkLiteral "var(foreground)";
            placeholder-color = mkLiteral "var(grayforeground)";
            placeholder = "Type to filter";
            cursor = mkLiteral "text";
          };
          "prompt" = {
            spacing = 0;
            text-color = mkLiteral "var(foreground)";
          };
          "textbox-prompt-colon" = {
            margin = mkLiteral "0px 0.3em 0em 0em";
            expand = false;
            str = ":";
            text-color = mkLiteral "inherit";
          };
          "mode-switch" = {
            border-color = mkLiteral "var(background)";
            border = 0;
          };
        };
        extraConfig = {
          modi = "drun,run";
        };
        font = "Monofur Nerd Font 12";
      };

      services.playerctld.enable = true;

      xdg.configFile = {
        "swappy/config".text = ''
          [Default]
          save_dir=$HOME/tmp
          save_filename_format=screenshot-%Y%m%d-%H%M%S.png
          show_panel=true
        '';

        "swaywsr/config.toml".text = ''
          [icons]
          "org.qutebrowser.qutebrowser" = "#"
          "Firefox" = "#"
          "Chromium-browser" = "#"
          "Alacritty" = ">"
          "Element" = "@"
          "discord" = "@"

          [aliases]
          "org.qutebrowser.qutebrowser" = "web"
          "Firefox" = "firefox"
          "Chromium-browser" = "chromium"
          "Alacritty" = "term"
          "Element" = "chat"
          "discord" = "discord"

          [general]
          default_icon = "*"
          separator = " | "

          [options]
          remove_duplicates = true
        '';
      };
    })
  ];

  environment.systemPackages = with pkgs; [
    qutebrowser
    imv
  ];

  fonts.fonts = with pkgs; [
    monofur-nerdfont
  ];

  environment.etc = {
    "xdg/mimeapps.list".text = lib.mkDefault ''
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
    '';

    "xdg/gtk-3.0/settings.ini".text = lib.mkDefault ''
      [Settings]
      gtk-theme-name=Materia-Fooster
      gtk-icon-theme-name=Papirus-Dark
      gtk-font-name=Monofur Nerd Font 12
      gtk-cursor-theme-name=Bibata-Modern-Classic
      gtk-application-prefer-dark-theme=true
    '';
    "gtk-3.0/settings.ini".source = config.environment.etc."xdg/gtk-3.0/settings.ini".source;

    "xdg/gtk-2.0/gtkrc".text = lib.mkDefault ''
      gtk-theme-name="Materia-Fooster"
      gtk-icon-theme-name="Papirus-Dark"
      gtk-font-name="Monofur Nerd Font 12"
      gtk-cursor-theme-name="Bibata-Modern-Classic"
    '';
    "gtk-2.0/gtkrc".source = config.environment.etc."xdg/gtk-2.0/gtkrc".source;

    "sway/config.d/fooster".text = lib.mkDefault ''
      ### variables
      set $mod mod4
      set $term ${pkgs.alacritty}/bin/alacritty
      set $run ${pkgs.rofi-wayland}/bin/rofi -show drun
      set $lock ${pkgs.swaylock}/bin/swaylock
      set $browser ${pkgs.qutebrowser}/bin/qutebrowser

      ### global settings
      font Monofur Nerd Font 12
      focus_follows_mouse yes
      mouse_warping output

      ### desktop settings
      default_border normal 2
      default_floating_border normal 2
      gaps inner 12

      ### color settings
      set $lock $lock -c 000000 --bs-hl-color 333333 --caps-lock-bs-hl-color 333333 --caps-lock-key-hl-color 333333 --font 'Monofur Nerd Font' --font-size 18 --inside-color 222222 --inside-clear-color 222222 --inside-caps-lock-color 222222 --inside-ver-color 333333 --inside-wrong-color 222222 --key-hl-color f29bd4 --line-color 222222 --ring-color 222222 --ring-clear-color 333333 --ring-caps-lock-color 222222 --ring-ver-color 333333 --ring-wrong-color aa4444 --separator-color 222222 --text-color f29bd4 --text-clear-color f29bd4 --text-caps-lock-color f29bd4 --text-ver-color f29bd4 --text-wrong-color f29bd4

      client.background #f29bd4
      client.focused #333333 #333333 #f29bd4 #f29bd4 #f29bd4
      client.focused_inactive #333333 #333333 #f29bd4 #f29bd4 #996185
      client.unfocused #333333 #333333 #996185 #f29bd4 #444444
      client.urgent #f29bd4 #f29bd4 #333333 #f29bd4 #444444

      ### rules
      for_window [title="Firefox — Sharing Indicator"] floating enable

      ### key bindings
      floating_modifier $mod normal

      #### sway
      bindsym $mod+q exit
      bindsym $mod+r reload

      #### windows
      bindsym $mod+shift+w kill

      #### containers
      bindsym $mod+h focus left
      bindsym $mod+j focus down
      bindsym $mod+k focus up
      bindsym $mod+l focus right
      bindsym $mod+left focus left
      bindsym $mod+down focus down
      bindsym $mod+up focus up
      bindsym $mod+right focus right

      bindsym $mod+g focus parent

      bindsym $mod+shift+h move left
      bindsym $mod+shift+j move down
      bindsym $mod+shift+k move up
      bindsym $mod+shift+l move right
      bindsym $mod+shift+left move left
      bindsym $mod+shift+down move down
      bindsym $mod+shift+up move up
      bindsym $mod+shift+right move right

      #### workspaces
      bindsym $mod+1 workspace number 1
      bindsym $mod+2 workspace number 2
      bindsym $mod+3 workspace number 3
      bindsym $mod+4 workspace number 4
      bindsym $mod+5 workspace number 5
      bindsym $mod+6 workspace number 6
      bindsym $mod+7 workspace number 7

      bindsym $mod+shift+1 move container to workspace number 1
      bindsym $mod+shift+2 move container to workspace number 2
      bindsym $mod+shift+3 move container to workspace number 3
      bindsym $mod+shift+4 move container to workspace number 4
      bindsym $mod+shift+5 move container to workspace number 5
      bindsym $mod+shift+6 move container to workspace number 6
      bindsym $mod+shift+7 move container to workspace number 7

      #### outputs
      bindsym $mod+alt+h focus output left
      bindsym $mod+alt+j focus output down
      bindsym $mod+alt+k focus output up
      bindsym $mod+alt+l focus output right
      bindsym $mod+alt+left focus output left
      bindsym $mod+alt+down focus output down
      bindsym $mod+alt+up focus output up
      bindsym $mod+alt+right focus output right

      bindsym $mod+shift+alt+h move container to output left
      bindsym $mod+shift+alt+j move container to output down
      bindsym $mod+shift+alt+k move container to output up
      bindsym $mod+shift+alt+l move container to output right
      bindsym $mod+shift+alt+left move container to output left
      bindsym $mod+shift+alt+down move container to output down
      bindsym $mod+shift+alt+up move container to output up
      bindsym $mod+shift+alt+right move container to output right

      #### layout
      bindsym $mod+ctrl+l splith
      bindsym $mod+ctrl+j splitv

      bindsym $mod+comma layout stacking
      bindsym $mod+period layout tabbed
      bindsym $mod+slash layout toggle split

      #### states
      bindsym $mod+i floating disable
      bindsym $mod+o floating enable
      bindsym $mod+p fullscreen

      bindsym $mod+shift+i sticky disable
      bindsym $mod+shift+o sticky enable

      bindsym $mod+apostrophe focus mode_toggle

      #### modes
      mode "resize" {
          bindsym h resize grow width 10 px or 10 ppt
          bindsym j resize shrink height 10 px or 10 ppt
          bindsym k resize grow height 10 px or 10 ppt
          bindsym l resize shrink width 10 px or 10 ppt

          bindsym down resize shrink height 10 px or 10 ppt
          bindsym left resize grow width 10 px or 10 ppt
          bindsym right resize shrink width 10 px or 10 ppt
          bindsym up resize grow height 10 px or 10 ppt

          bindsym return mode "default"
          bindsym escape mode "default"
      }

      bindsym $mod+t mode "resize"

      #### buttons
      bindsym xf86monbrightnessdown exec ${pkgs.brightnessctl}/bin/brightnessctl -c backlight set 10%-
      bindsym xf86monbrightnessup exec ${pkgs.brightnessctl}/bin/brightnessctl -c backlight set 10%+
      bindsym shift+xf86monbrightnessdown exec ${pkgs.brightnessctl}/bin/brightnessctl -c backlight set 1%-
      bindsym shift+xf86monbrightnessup exec ${pkgs.brightnessctl}/bin/brightnessctl -c backlight set 1%+
      bindsym $mod+xf86monbrightnessdown exec ${pkgs.brightnessctl}/bin/brightnessctl -c backlight set 0%
      bindsym $mod+xf86monbrightnessup exec ${pkgs.brightnessctl}/bin/brightnessctl -c backlight set 100%

      bindsym xf86kbdbrightnessdown exec ${pkgs.brightnessctl}/bin/brightnessctl -c leds set 10%-
      bindsym xf86kbdbrightnessup exec ${pkgs.brightnessctl}/bin/brightnessctl -c leds set 10%+
      bindsym shift+xf86kbdbrightnessdown exec ${pkgs.brightnessctl}/bin/brightnessctl -c leds set 1%-
      bindsym shift+xf86kbdbrightnessup exec ${pkgs.brightnessctl}/bin/brightnessctl -c leds set 1%+
      bindsym $mod+xf86kbdbrightnessdown exec ${pkgs.brightnessctl}/bin/brightnessctl -c leds set 0%
      bindsym $mod+xf86kbdbrightnessup exec ${pkgs.brightnessctl}/bin/brightnessctl -c leds set 100%

      bindsym xf86audiolowervolume exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume 0 -10%
      bindsym xf86audioraisevolume exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume 0 +10%
      bindsym shift+xf86audiolowervolume exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume 0 -1%
      bindsym shift+xf86audioraisevolume exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume 0 +1%
      bindsym $mod+xf86audiolowervolume exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume 0 0%
      bindsym $mod+xf86audioraisevolume exec ${pkgs.pulseaudio}/bin/pactl set-sink-volume 0 100%
      bindsym xf86audiomute exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute 0 toggle

      bindsym xf86audioplay exec ${pkgs.playerctl}/bin/playerctl play-pause
      bindsym xf86audiostop exec ${pkgs.playerctl}/bin/playerctl stop
      bindsym xf86audioprev exec ${pkgs.playerctl}/bin/playerctl previous
      bindsym xf86audionext exec ${pkgs.playerctl}/bin/playerctl next

      #### applications
      bindsym $mod+semicolon exec $term
      bindsym $mod+return exec $run
      bindsym $mod+space exec $lock
      bindsym $mod+a exec $browser

      #### shortcuts
      bindsym $mod+print exec ${pkgs.sway-contrib.grimshot}/bin/grimshot save output - | ${pkgs.swappy}/bin/swappy -f -
      bindsym $mod+shift+print exec ${pkgs.sway-contrib.grimshot}/bin/grimshot save area - | ${pkgs.swappy}/bin/swappy -f -
      bindsym $mod+ctrl+print exec ${pkgs.sway-contrib.grimshot}/bin/grimshot save window - | ${pkgs.swappy}/bin/swappy -f -
      bindsym $mod+alt+print exec ${pkgs.sway-contrib.grimshot}/bin/grimshot save screen - | ${pkgs.swappy}/bin/swappy -f -
      bindsym $mod+bracketright exec ${pkgs.mako}/bin/makoctl dismiss -g
      bindsym $mod+shift+bracketright exec ${pkgs.mako}/bin/makoctl dismiss -a
      bindsym $mod+ctrl+bracketright exec ${pkgs.mako}/bin/makoctl restore
      bindsym $mod+bracketleft exec ${pkgs.mako}/bin/makoctl invoke

      ### desktop elements
      output * background #111111 solid_color
      bar {
          position top

          icon_theme Papirus-Dark

          font Monofur Nerd Font 12
          colors {
              background #222222
              statusline #dadada
              separator #f29bd4

              focused_workspace #f29bd4 #f29bd4 #333333
              active_workspace #996185 #f29bd4 #333333
              inactive_workspace #333333 #333333 #f29bd4
              urgent_workspace #333333 #aa4444 #333333
          }

          separator_symbol " • "

          status_command i3status
      }

      ### desktop services
      exec_always ${pkgs.fooster-backgrounds}/bin/setbg
      exec_always ${pkgs.swaywsr}/bin/swaywsr -c "$HOME"/.config/swaywsr/config.toml

      ### desktop environment
      seat seat0 xcursor_theme "Bibata-Modern-Classic"
    '';

    "xdg/i3status/config".text = lib.mkDefault ''
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

      disk / {
          format = "disk: %avail"
      }

      tztime local {
          format = "%H:%M"
      }
    '';

    "xdg/i3status/tmux".text = lib.mkDefault ''
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
      order += "disk /"
      order += "tztime local"

      load {
          format = "cpu: %1min"
      }

      cpu_temperature 0 {
          format = "temp: %degrees °C"
      }

      disk / {
          format = "disk: %avail"
      }

      tztime local {
          format = "%H:%M"
      }
    '';

    "xdg/alacritty/alacritty.yml".text = ''
      font:
        normal:
          family: Monofur Nerd Font
          style: Regular

        bold:
          family: Monofurbold Nerd Font
          style: Bold

        italic:
          family: Monofuritalic Nerd Font
          style: Italic

        bold_italic:
          family: Monofurbold Nerd Font
          style: Bold Italic

        size: 13
    '';

    "petty/pettyrc".text = ''
      shell=${pkgs.bashInteractive}/bin/bash
      session1=sway
    '';

    "sessions/sway".source = pkgs.writeScript "sway" ''
      #!/bin/sh
      mkdir -p "$HOME"/.local/share/sway
      exec sway -d >"$HOME"/.local/share/sway/sway.log 2>&1
    '';
  };

  qt5 = {
    enable = true;
    style = "adwaita-dark";
    platformTheme = "gnome";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    gtkUsePortal = true;
  };

  programs.dconf.profiles.sway = sway-dconf-profile;

  programs.tmux.extraConfig = ''
    # status
    set -g status-interval 60
    set -g status-right-length 70
    set -g status-right '#(hostname -s) • #(i3status -c /etc/xdg/i3status/tmux)'
  '';

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      pulseaudio brightnessctl playerctl jq glib
      swaybg swaylock swayidle
      kanshi i3status swaywsr mako rofi-wayland alacritty
      fooster-backgrounds fooster-materia-theme bibata-cursors papirus-icon-theme
      slurp grim wl-clipboard libnotify sway-contrib.grimshot swappy wf-recorder wl-mirror
      xwayland
      xdg-utils
    ];
    extraSessionCommands = ''
      export XDG_SESSION_TYPE=wayland
      export DCONF_PROFILE=sway
    '';
  };

  programs.kanshi.enable = true;

  programs.mako = {
    enable = true;
    extraConfig = ''
      background-color=#222222
      border-size=0
      font=Monofur Nerd Font 12
      icon-path=${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark
      margin=12
      progress-color=over #333333
      text-color=#f29bd4
    '';
  };
}
