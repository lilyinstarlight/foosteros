{ config, lib, pkgs, ... }:

let
  # TODO: replace theme stuff with catppuccin
  sway-dconf-settings = pkgs.writeTextFile {
    name = "sway-dconf-settings";
    destination = "/dconf/sway-custom";
    text = ''
      [org/gnome/desktop/interface]
      gtk-theme='Materia-Fooster'
      icon-theme='Papirus-Dark'
      cursor-theme='Bibata-Modern-Classic'
    '';
  };

  sway-dconf-db = pkgs.runCommand "sway-dconf-db" { preferLocalBuild = true; nativeBuildInputs = with pkgs; [ dconf ]; } ''
    dconf compile $out ${sway-dconf-settings}/dconf
  '';

  sway-dconf-profile = pkgs.writeText "sway-dconf-profile" ''
    user-db:user
    file-db:${sway-dconf-db}
  '';

  sway-default-icon-theme = pkgs.writeTextFile {
    name = "sway-default-icon-theme";
    destination = "/share/icons/default/index.theme";
    text = ''
      [icon theme]
      Inherits=Papirus-Dark;Bibata-Modern-Classic
    '';
  };

  polkit-sway = pkgs.runCommand "polkit-sway" { preferLocalBuild = true; } ''
    mkdir -p $out/etc/xdg/autostart/
    sed -e 's/^OnlyShowIn=.*$/OnlyShowIn=sway;/' ${pkgs.polkit_gnome}/etc/xdg/autostart/polkit-gnome-authentication-agent-1.desktop >$out/etc/xdg/autostart/polkit-sway-authentication-agent-1.desktop
  '';
in

{
  imports = [
    ./fonts.nix
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
      };
    })
  ];

  fonts.fonts = with pkgs; [
    monofur-nerdfont
  ];

  environment.systemPackages = with pkgs; [
    qutebrowser
    imv mupdf mpv
  ];

  environment.variables = {
    NIXOS_OZONE_WL = "1";
  };

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
      application/pdf=mupdf.desktop
      application/x-pdf=mupdf.desktop
      application/x-cbz=mupdf.desktop
      application/oxps=mupdf.desktop
      application/vnd.ms-xpsdocument=mupdf.desktop
      application/epub+zip=mupdf.desktop
      application/ogg=mpv.desktop
      application/x-ogg=mpv.desktop
      application/mxf=mpv.desktop
      application/sdp=mpv.desktop
      application/smil=mpv.desktop
      application/x-smil=mpv.desktop
      application/streamingmedia=mpv.desktop
      application/x-streamingmedia=mpv.desktop
      application/vnd.rn-realmedia=mpv.desktop
      application/vnd.rn-realmedia-vbr=mpv.desktop
      audio/aac=mpv.desktop
      audio/x-aac=mpv.desktop
      audio/vnd.dolby.heaac.1=mpv.desktop
      audio/vnd.dolby.heaac.2=mpv.desktop
      audio/aiff=mpv.desktop
      audio/x-aiff=mpv.desktop
      audio/m4a=mpv.desktop
      audio/x-m4a=mpv.desktop
      application/x-extension-m4a=mpv.desktop
      audio/mp1=mpv.desktop
      audio/x-mp1=mpv.desktop
      audio/mp2=mpv.desktop
      audio/x-mp2=mpv.desktop
      audio/mp3=mpv.desktop
      audio/x-mp3=mpv.desktop
      audio/mpeg=mpv.desktop
      audio/mpeg2=mpv.desktop
      audio/mpeg3=mpv.desktop
      audio/mpegurl=mpv.desktop
      audio/x-mpegurl=mpv.desktop
      audio/mpg=mpv.desktop
      audio/x-mpg=mpv.desktop
      audio/rn-mpeg=mpv.desktop
      audio/musepack=mpv.desktop
      audio/x-musepack=mpv.desktop
      audio/ogg=mpv.desktop
      audio/scpls=mpv.desktop
      audio/x-scpls=mpv.desktop
      audio/vnd.rn-realaudio=mpv.desktop
      audio/wav=mpv.desktop
      audio/x-pn-wav=mpv.desktop
      audio/x-pn-windows-pcm=mpv.desktop
      audio/x-realaudio=mpv.desktop
      audio/x-pn-realaudio=mpv.desktop
      audio/x-ms-wma=mpv.desktop
      audio/x-pls=mpv.desktop
      audio/x-wav=mpv.desktop
      video/mpeg=mpv.desktop
      video/x-mpeg2=mpv.desktop
      video/x-mpeg3=mpv.desktop
      video/mp4v-es=mpv.desktop
      video/x-m4v=mpv.desktop
      video/mp4=mpv.desktop
      application/x-extension-mp4=mpv.desktop
      video/divx=mpv.desktop
      video/vnd.divx=mpv.desktop
      video/msvideo=mpv.desktop
      video/x-msvideo=mpv.desktop
      video/ogg=mpv.desktop
      video/quicktime=mpv.desktop
      video/vnd.rn-realvideo=mpv.desktop
      video/x-ms-afs=mpv.desktop
      video/x-ms-asf=mpv.desktop
      audio/x-ms-asf=mpv.desktop
      application/vnd.ms-asf=mpv.desktop
      video/x-ms-wmv=mpv.desktop
      video/x-ms-wmx=mpv.desktop
      video/x-ms-wvxvideo=mpv.desktop
      video/x-avi=mpv.desktop
      video/avi=mpv.desktop
      video/x-flic=mpv.desktop
      video/fli=mpv.desktop
      video/x-flc=mpv.desktop
      video/flv=mpv.desktop
      video/x-flv=mpv.desktop
      video/x-theora=mpv.desktop
      video/x-theora+ogg=mpv.desktop
      video/x-matroska=mpv.desktop
      video/mkv=mpv.desktop
      audio/x-matroska=mpv.desktop
      application/x-matroska=mpv.desktop
      video/webm=mpv.desktop
      audio/webm=mpv.desktop
      audio/vorbis=mpv.desktop
      audio/x-vorbis=mpv.desktop
      audio/x-vorbis+ogg=mpv.desktop
      video/x-ogm=mpv.desktop
      video/x-ogm+ogg=mpv.desktop
      application/x-ogm=mpv.desktop
      application/x-ogm-audio=mpv.desktop
      application/x-ogm-video=mpv.desktop
      application/x-shorten=mpv.desktop
      audio/x-shorten=mpv.desktop
      audio/x-ape=mpv.desktop
      audio/x-wavpack=mpv.desktop
      audio/x-tta=mpv.desktop
      audio/AMR=mpv.desktop
      audio/ac3=mpv.desktop
      audio/eac3=mpv.desktop
      audio/amr-wb=mpv.desktop
      video/mp2t=mpv.desktop
      audio/flac=mpv.desktop
      audio/mp4=mpv.desktop
      application/x-mpegurl=mpv.desktop
      video/vnd.mpegurl=mpv.desktop
      application/vnd.apple.mpegurl=mpv.desktop
      audio/x-pn-au=mpv.desktop
      video/3gp=mpv.desktop
      video/3gpp=mpv.desktop
      video/3gpp2=mpv.desktop
      audio/3gpp=mpv.desktop
      audio/3gpp2=mpv.desktop
      video/dv=mpv.desktop
      audio/dv=mpv.desktop
      audio/opus=mpv.desktop
      audio/vnd.dts=mpv.desktop
      audio/vnd.dts.hd=mpv.desktop
      audio/x-adpcm=mpv.desktop
      application/x-cue=mpv.desktop
      audio/m3u=mpv.desktop
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
      set $lock ${pkgs.systemd}/bin/loginctl lock-session
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
      ${lib.optionalString (config.system.devices.coreThermalZone != null) ''
        order += "cpu_temperature ${toString config.system.devices.coreThermalZone}"
      ''}
      order += "volume master"
      ${lib.optionalString (config.system.devices.wirelessAdapter != null) ''
        order += "wireless ${config.system.devices.wirelessAdapter}"
      ''}
      ${lib.optionalString (config.system.devices.batteryId != null) ''
        order += "battery ${toString config.system.devices.batteryId}"
      ''}
      order += "disk /"
      order += "tztime local"

      load {
          format = "cpu: %1min"
      }

      ${lib.optionalString (config.system.devices.coreThermalZone != null) ''
        cpu_temperature ${toString config.system.devices.coreThermalZone} {
            format = "temp: %degrees °C"
        }
      ''}

      volume master {
          format = "vol: %volume"
          format_muted = "vol: mute"
      }

      ${lib.optionalString (config.system.devices.wirelessAdapter != null) ''
        wireless ${config.system.devices.wirelessAdapter} {
            format_up = "wlan: %essid"
            format_down = "wlan: off"
        }
      ''}

      ${lib.optionalString (config.system.devices.batteryId != null) ''
        battery ${toString config.system.devices.batteryId} {
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
      ''}

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
      ${lib.optionalString (config.system.devices.coreThermalZone != null) ''
        order += "cpu_temperature ${toString config.system.devices.coreThermalZone}"
      ''}
      ${lib.optionalString (config.system.devices.batteryId != null) ''
        order += "battery ${toString config.system.devices.batteryId}"
      ''}
      order += "disk /"
      order += "tztime local"

      load {
          format = "cpu: %1min"
      }

      ${lib.optionalString (config.system.devices.coreThermalZone != null) ''
        cpu_temperature ${toString config.system.devices.coreThermalZone} {
            format = "temp: %degrees °C"
        }
      ''}

      ${lib.optionalString (config.system.devices.batteryId != null) ''
        battery ${toString config.system.devices.batteryId} {
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
      ''}

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
  };

  qt = {
    enable = true;
    style = "adwaita-dark";
    platformTheme = "gnome";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --greeting 'Welcome to FoosterOS/2 Warp' --time --time-format '%Y-%m-%d %H:%M' --cmd sway-session";
    };
  };

  services.xserver.gdk-pixbuf.modulePackages = with pkgs; [ librsvg ];

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
      swaybg swaylock-fprintd swayidle
      kanshi i3status swaywsr mako rofi-wayland alacritty
      polkit-sway
      fooster-backgrounds fooster-materia-theme bibata-cursors papirus-icon-theme sway-default-icon-theme
      slurp grim wl-clipboard libnotify sway-contrib.grimshot swappy wf-recorder wl-mirror
      xwayland
      xdg-utils
      (pkgs.writeShellScriptBin "sway-session" ''
        mkdir -p "$HOME"/.local/share/sway
        exec sway -d >"$HOME"/.local/share/sway/sway.log 2>&1
      '')
    ];
    extraSessionCommands = ''
      export XDG_SESSION_TYPE=wayland
      export DCONF_PROFILE=sway
    '';
  };

  programs.swayidle = {
    enable = true;
    events = [
      { event = "before-sleep"; command = "${pkgs.systemd}/bin/loginctl lock-session"; }
      { event = "lock"; command = "${pkgs.swaylock-fprintd}/bin/swaylock -f -c 000000 --bs-hl-color 333333 --caps-lock-bs-hl-color 333333 --caps-lock-key-hl-color 333333 --font 'Monofur Nerd Font' --font-size ${if config.hardware.video.hidpi.enable then "28" else "18"} --inside-color 222222 --inside-clear-color 222222 --inside-caps-lock-color 222222 --inside-ver-color 333333 --inside-wrong-color 222222 --key-hl-color f29bd4 --line-color 222222 --ring-color 222222 --ring-clear-color 333333 --ring-caps-lock-color 222222 --ring-ver-color 333333 --ring-wrong-color aa4444 --separator-color 222222 --text-color f29bd4 --text-clear-color f29bd4 --text-caps-lock-color f29bd4 --text-ver-color f29bd4 --text-wrong-color f29bd4"; }
      { event = "unlock"; command = "${pkgs.procps}/bin/pkill --session \"$XDG_SESSION_ID\" -USR1 swaylock"; }
    ];
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

  programs.swaywsr = {
    enable = true;
    extraConfig = ''
      [icons]
      "org.qutebrowser.qutebrowser" = "#"
      "firefox" = "#"
      "Chromium-browser" = "#"
      "Alacritty" = ">"
      "Element" = "@"
      "discord" = "@"

      [aliases]
      "org.qutebrowser.qutebrowser" = "web"
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

  programs.swaynag-battery = lib.mkIf (config.system.devices.batteryId != null) {
    enable = true;
    powerSupply = "BAT${toString config.system.devices.batteryId}";
  };
}
