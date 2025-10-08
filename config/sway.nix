{ config, lib, pkgs, ... }:

let
  sway-dconf-settings = pkgs.writeTextFile {
    name = "sway-dconf-settings";
    destination = "/dconf/sway-custom";
    text = ''
      [org/gnome/desktop/interface]
      gtk-theme='Colloid-Pink-Dark-Catppuccin'
      icon-theme='Papirus-Dark'
      font-name='monospace 12'
      cursor-theme='catppuccin-mocha-dark-cursors'
      color-scheme='prefer-dark'
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
      Inherits=Papirus-Dark;catppuccin-mocha-dark-cursors
    '';
  };

  polkit-sway = pkgs.runCommand "polkit-sway" { preferLocalBuild = true; } ''
    mkdir -p $out/etc/xdg/autostart/
    sed -e 's/^OnlyShowIn=.*$/OnlyShowIn=sway;/' ${pkgs.polkit_gnome}/etc/xdg/autostart/polkit-gnome-authentication-agent-1.desktop >$out/etc/xdg/autostart/polkit-sway-authentication-agent-1.desktop
  '';

  pinentry-rofi = pkgs.pinentry-rofi.overrideAttrs (old: {
    patches = old.patches or [] ++ [
      (pkgs.writeText "pinentry-rofi-fixes.patch" ''
        diff --git a/pinentry-rofi.scm b/pinentry-rofi.scm
        index 67fb2f0..cb159fa 100755
        --- a/pinentry-rofi.scm
        +++ b/pinentry-rofi.scm
        @@ -365,7 +365,7 @@ Return the input from the user if succeeded else #f."
                 (regex-match #f))
             (when (set-and-return! regex-match (regexp-exec getpin-re line))
               (let ((pass (pin-program #:title (pinentry-title pinentry)
        -                               #:prompt (pinentry-prompt pinentry)
        +                               #:prompt (string-trim-right (pinentry-prompt pinentry) #\:)
                                        #:message (compose-message pinentry)
                                        #:visibility (pinentry-visibility pinentry)
                                        #:env `(("DISPLAY" . ,(pinentry-display pinentry))
      '')
    ];
  });

  colloid-gtk-theme-sway = pkgs.colloid-gtk-theme.override {
    tweaks = [ "catppuccin" ];
    colorVariants = [ "dark" ];
    themeVariants = [ "pink" ];
  };

  catppuccin-cursors-sway = pkgs.catppuccin-cursors.mochaDark;
in

lib.mkIf config.foosteros.profiles.sway {
  foosteros.profiles = {
    fonts = lib.mkDefault true;
    pipewire = lib.mkDefault true;
  };

  home-manager.sharedModules = [
    ({ config, lib, pkgs, ... }: {
      programs.qutebrowser = {
        enable = true;
        loadAutoconfig = true;
        settings = {
          colors.webpage.preferred_color_scheme = "dark";
          content.pdfjs = true;
          downloads.location.prompt = false;
          editor.command = ["alacritty" "-e" "vi" "{}"];
          fonts = {
            default_family = "monospace";
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
        package = pkgs.rofi;
        terminal = "alacritty";
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
        font = "monospace 12";
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

  fonts.packages = with pkgs; [
    nerd-fonts.monofur
  ];

  fonts.fontconfig.defaultFonts.monospace = [
    "Monofur Nerd Font"
    "Noto Color Emoji"
  ];

  environment.systemPackages = with pkgs; [
    qutebrowser
    alacritty
    imv mupdf mpv
  ];

  environment.variables = {
    NIXOS_OZONE_WL = "1";
  };

  xdg.mime.defaultApplications = lib.listToAttrs (lib.flatten (lib.mapAttrsToList (app: mimes: lib.map (mime: lib.nameValuePair mime (lib.mkDefault app)) mimes) {
    "org.qutebrowser.qutebrowser.desktop" = [
      "application/rdf+xml"
      "application/xhtml+xml"
      "application/xml"
      "text/html"
      "text/xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
    "imv.desktop" = [
      "image/bmp"
      "image/gif"
      "image/heif"
      "image/jpeg"
      "image/png"
      "image/tiff"
    ];
    "mupdf.desktop" = [
      "application/epub+zip"
      "application/oxps"
      "application/pdf"
      "application/vnd.ms-xpsdocument"
      "application/x-cbz"
      "application/x-pdf"
    ];
    "mpv.desktop" = [
      "application/mxf"
      "application/ogg"
      "application/sdp"
      "application/smil"
      "application/streamingmedia"
      "application/vnd.apple.mpegurl"
      "application/vnd.ms-asf"
      "application/vnd.rn-realmedia"
      "application/vnd.rn-realmedia-vbr"
      "application/x-cue"
      "application/x-extension-m4a"
      "application/x-extension-mp4"
      "application/x-matroska"
      "application/x-mpegurl"
      "application/x-ogg"
      "application/x-ogm"
      "application/x-ogm-audio"
      "application/x-ogm-video"
      "application/x-shorten"
      "application/x-smil"
      "application/x-streamingmedia"
      "audio/3gpp"
      "audio/3gpp2"
      "audio/AMR"
      "audio/aac"
      "audio/ac3"
      "audio/aiff"
      "audio/amr-wb"
      "audio/dv"
      "audio/eac3"
      "audio/flac"
      "audio/m3u"
      "audio/m4a"
      "audio/mp1"
      "audio/mp2"
      "audio/mp3"
      "audio/mp4"
      "audio/mpeg"
      "audio/mpeg2"
      "audio/mpeg3"
      "audio/mpegurl"
      "audio/mpg"
      "audio/musepack"
      "audio/ogg"
      "audio/opus"
      "audio/rn-mpeg"
      "audio/scpls"
      "audio/vnd.dolby.heaac.1"
      "audio/vnd.dolby.heaac.2"
      "audio/vnd.dts"
      "audio/vnd.dts.hd"
      "audio/vnd.rn-realaudio"
      "audio/vorbis"
      "audio/wav"
      "audio/webm"
      "audio/x-aac"
      "audio/x-adpcm"
      "audio/x-aiff"
      "audio/x-ape"
      "audio/x-m4a"
      "audio/x-matroska"
      "audio/x-mp1"
      "audio/x-mp2"
      "audio/x-mp3"
      "audio/x-mpegurl"
      "audio/x-mpg"
      "audio/x-ms-asf"
      "audio/x-ms-wma"
      "audio/x-musepack"
      "audio/x-pls"
      "audio/x-pn-au"
      "audio/x-pn-realaudio"
      "audio/x-pn-wav"
      "audio/x-pn-windows-pcm"
      "audio/x-realaudio"
      "audio/x-scpls"
      "audio/x-shorten"
      "audio/x-tta"
      "audio/x-vorbis"
      "audio/x-vorbis+ogg"
      "audio/x-wav"
      "audio/x-wavpack"
      "video/3gp"
      "video/3gpp"
      "video/3gpp2"
      "video/avi"
      "video/divx"
      "video/dv"
      "video/fli"
      "video/flv"
      "video/mkv"
      "video/mp2t"
      "video/mp4"
      "video/mp4v-es"
      "video/mpeg"
      "video/msvideo"
      "video/ogg"
      "video/quicktime"
      "video/vnd.divx"
      "video/vnd.mpegurl"
      "video/vnd.rn-realvideo"
      "video/webm"
      "video/x-avi"
      "video/x-flc"
      "video/x-flic"
      "video/x-flv"
      "video/x-m4v"
      "video/x-matroska"
      "video/x-mpeg2"
      "video/x-mpeg3"
      "video/x-ms-afs"
      "video/x-ms-asf"
      "video/x-ms-wmv"
      "video/x-ms-wmx"
      "video/x-ms-wvxvideo"
      "video/x-msvideo"
      "video/x-ogm"
      "video/x-ogm+ogg"
      "video/x-theora"
      "video/x-theora+ogg"
    ];
  }));

  environment.etc = {
    "xdg/gtk-4.0/settings.ini".text = lib.mkDefault ''
      [Settings]
      gtk-theme-name=Colloid-Pink-Dark-Catppuccin
      gtk-icon-theme-name=Papirus-Dark
      gtk-font-name=monospace 12
      gtk-cursor-theme-name=catppuccin-mocha-dark-cursors
      gtk-application-prefer-dark-theme=true
    '';
    "gtk-4.0/settings.ini".source = config.environment.etc."xdg/gtk-3.0/settings.ini".source;

    "xdg/gtk-3.0/settings.ini".text = lib.mkDefault ''
      [Settings]
      gtk-theme-name=Colloid-Pink-Dark-Catppuccin
      gtk-icon-theme-name=Papirus-Dark
      gtk-font-name=monospace 12
      gtk-cursor-theme-name=catppuccin-mocha-dark-cursors
      gtk-application-prefer-dark-theme=true
    '';
    "gtk-3.0/settings.ini".source = config.environment.etc."xdg/gtk-3.0/settings.ini".source;

    "xdg/gtk-2.0/gtkrc".text = lib.mkDefault ''
      gtk-theme-name="Colloid-Pink-Dark-Catppuccin"
      gtk-icon-theme-name="Papirus-Dark"
      gtk-font-name="monospace 12"
      gtk-cursor-theme-name="catppuccin-mocha-dark-cursors"
    '';
    "gtk-2.0/gtkrc".source = config.environment.etc."xdg/gtk-2.0/gtkrc".source;

    "sway/config.d/fooster".text = lib.mkDefault ''
      ### variables
      set $mod mod4
      set $term alacritty
      set $run ${lib.getExe pkgs.rofi} -show drun
      set $lock ${lib.getExe' pkgs.systemd "loginctl"} lock-session
      set $browser qutebrowser

      ### global settings
      font monospace 12
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
      bindsym xf86monbrightnessdown exec ${lib.getExe pkgs.brightnessctl} -c backlight set 10%-
      bindsym xf86monbrightnessup exec ${lib.getExe pkgs.brightnessctl} -c backlight set 10%+
      bindsym shift+xf86monbrightnessdown exec ${lib.getExe pkgs.brightnessctl} -c backlight set 1%-
      bindsym shift+xf86monbrightnessup exec ${lib.getExe pkgs.brightnessctl} -c backlight set 1%+
      bindsym $mod+xf86monbrightnessdown exec ${lib.getExe pkgs.brightnessctl} -c backlight set 0%
      bindsym $mod+xf86monbrightnessup exec ${lib.getExe pkgs.brightnessctl} -c backlight set 100%

      bindsym xf86kbdbrightnessdown exec ${lib.getExe pkgs.brightnessctl} -c leds set 10%-
      bindsym xf86kbdbrightnessup exec ${lib.getExe pkgs.brightnessctl} -c leds set 10%+
      bindsym shift+xf86kbdbrightnessdown exec ${lib.getExe pkgs.brightnessctl} -c leds set 1%-
      bindsym shift+xf86kbdbrightnessup exec ${lib.getExe pkgs.brightnessctl} -c leds set 1%+
      bindsym $mod+xf86kbdbrightnessdown exec ${lib.getExe pkgs.brightnessctl} -c leds set 0%
      bindsym $mod+xf86kbdbrightnessup exec ${lib.getExe pkgs.brightnessctl} -c leds set 100%

      bindsym xf86audiolowervolume exec ${lib.getExe' pkgs.pulseaudio "pactl"} set-sink-volume 0 -10%
      bindsym xf86audioraisevolume exec ${lib.getExe' pkgs.pulseaudio "pactl"} set-sink-volume 0 +10%
      bindsym shift+xf86audiolowervolume exec ${lib.getExe' pkgs.pulseaudio "pactl"} set-sink-volume 0 -1%
      bindsym shift+xf86audioraisevolume exec ${lib.getExe' pkgs.pulseaudio "pactl"} set-sink-volume 0 +1%
      bindsym $mod+xf86audiolowervolume exec ${lib.getExe' pkgs.pulseaudio "pactl"} set-sink-volume 0 0%
      bindsym $mod+xf86audioraisevolume exec ${lib.getExe' pkgs.pulseaudio "pactl"} set-sink-volume 0 100%
      bindsym xf86audiomute exec ${lib.getExe' pkgs.pulseaudio "pactl"} set-sink-mute 0 toggle

      bindsym xf86audioplay exec ${lib.getExe pkgs.playerctl} play-pause
      bindsym xf86audiostop exec ${lib.getExe pkgs.playerctl} stop
      bindsym xf86audioprev exec ${lib.getExe pkgs.playerctl} previous
      bindsym xf86audionext exec ${lib.getExe pkgs.playerctl} next

      #### applications
      bindsym $mod+semicolon exec $term
      bindsym $mod+return exec $run
      bindsym $mod+space exec $lock
      bindsym $mod+a exec $browser

      #### shortcuts
      bindsym $mod+print exec ${lib.getExe pkgs.sway-contrib.grimshot} save output - | ${lib.getExe pkgs.swappy} -f -
      bindsym $mod+shift+print exec ${lib.getExe pkgs.sway-contrib.grimshot} save area - | ${lib.getExe pkgs.swappy} -f -
      bindsym $mod+ctrl+print exec ${lib.getExe pkgs.sway-contrib.grimshot} save window - | ${lib.getExe pkgs.swappy} -f -
      bindsym $mod+alt+print exec ${lib.getExe pkgs.sway-contrib.grimshot} save screen - | ${lib.getExe pkgs.swappy} -f -
      bindsym $mod+bracketright exec ${lib.getExe' pkgs.mako "makoctl"} dismiss -g
      bindsym $mod+shift+bracketright exec ${lib.getExe' pkgs.mako "makoctl"} dismiss -a
      bindsym $mod+ctrl+bracketright exec ${lib.getExe' pkgs.mako "makoctl"} restore
      bindsym $mod+bracketleft exec ${lib.getExe' pkgs.mako "makoctl"} invoke

      ### desktop elements
      output * background #111111 solid_color
      bar {
          position top

          icon_theme Papirus-Dark

          font monospace 12
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
      exec_always ${lib.getExe' pkgs.fooster-backgrounds "setbg"}

      ### desktop environment
      seat seat0 xcursor_theme "catppuccin-mocha-dark-cursors"
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

    "xdg/alacritty/alacritty.toml".text = ''
      [font]
      size = 13

      [font.bold]
      family = "monospace"
      style = "Bold"

      [font.bold_italic]
      family = "monospace"
      style = "Bold Italic"

      [font.italic]
      family = "monospace"
      style = "Italic"

      [font.normal]
      family = "monospace"
      style = "Regular"
    '';
  };

  boot.loader.timeout = 0;

  boot.plymouth = {
    enable = true;
    theme = "nixos-bgrt";
    themePackages = [ pkgs.nixos-bgrt-plymouth ];
  };

  security.pam.loginLimits = [
    { domain = "@users"; item = "rtprio"; type = "-"; value = 1; }
  ];

  # TODO: use qt5ct/qt6ct theme with lightly style once Luwx/Lightly#200 is finished
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  services.displayManager.sessionPackages = [
    (lib.hiPrio (pkgs.runCommand "sway-session.desktop" {
      desktopItem = pkgs.makeDesktopItem {
        name = "sway";
        desktopName = "Sway";
        comment = "An i3-compatible Wayland compositor";
        exec = "sway-session";
      };
      passthru.providedSessions = [ "sway" ];
    } ''
      install -Dt $out/share/wayland-sessions $desktopItem/share/applications/*
    ''))
  ];

  programs.regreet = {
    enable = true;
    theme.name = "Colloid-Pink-Dark-Catppuccin";
    iconTheme.name = "Papirus-Dark";
    font.name = "monospace 12";
    cursorTheme.name = "catppuccin-mocha-dark-cursors";
  };
  services.greetd.settings.default_session.command = let
    greetdSwayConfig = pkgs.writeText "greetd-sway-config" ''
      font monospace 12
      output * background #111111 solid_color
      seat seat0 xcursor_theme "catppuccin-mocha-dark-cursors"
      xwayland disable
      exec "command -v dbus-update-activation-environment >/dev/null 2>&1 && dbus-update-activation-environment --systemd PATH XDG_SESSION_CLASS XDG_CONFIG_DIRS XDG_DATA_DIRS XDG_SESSION_DESKTOP XDG_CURRENT_DESKTOP XDG_SESSION_TYPE DCONF_PROFILE XDG_DESKTOP_PORTAL_DIR DISPLAY WAYLAND_DISPLAY SWAYSOCK XMODIFIERS XCURSOR_SIZE XCURSOR_THEME GDK_PIXBUF_MODULE_FILE GIO_EXTRA_MODULES GTK_IM_MODULE QT_PLUGIN_PATH QT_QPA_PLATFORMTHEME QT_STYLE_OVERRIDE QT_IM_MODULE NIXOS_OZONE_WL || systemctl --user import-environment PATH XDG_SESSION_CLASS XDG_CONFIG_DIRS XDG_DATA_DIRS XDG_SESSION_DESKTOP XDG_CURRENT_DESKTOP XDG_SESSION_TYPE DCONF_PROFILE XDG_DESKTOP_PORTAL_DIR DISPLAY WAYLAND_DISPLAY SWAYSOCK XMODIFIERS XCURSOR_SIZE XCURSOR_THEME GDK_PIXBUF_MODULE_FILE GIO_EXTRA_MODULES GTK_IM_MODULE QT_PLUGIN_PATH QT_QPA_PLATFORMTHEME QT_STYLE_OVERRIDE QT_IM_MODULE NIXOS_OZONE_WL"
      exec "${lib.getExe config.programs.regreet.package} >/var/log/regreet/stdio 2>&1; swaymsg exit"
    '';
  in "${lib.getExe config.programs.sway.package} --config ${greetdSwayConfig}";
  systemd.tmpfiles.rules = let
    regreetUsers = lib.concatMap (user: lib.optional user.isNormalUser user.name) (lib.attrValues config.users.users);
    regreetCache = pkgs.writeText "regreet-cache.toml" (''
      last_user = "${lib.head regreetUsers}"

      [user_to_last_sess]
    '' + lib.concatMapStrings (user: "${user} = \"Sway\"\n") regreetUsers);
  in lib.optionals (regreetUsers != []) [ "L+ /var/lib/regreet/state.toml - - - - ${regreetCache}" ];

  programs.gdk-pixbuf.modulePackages = with pkgs; [ librsvg ];

  programs.gnupg.agent.pinentryPackage = pkgs.writeShellApplication {
    name = "pinentry-rofi";
    runtimeInputs = with pkgs; [ rofi ];
    text = ''
      exec ${pinentry-rofi}/bin/pinentry-rofi "$@"
    '';
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
      swaybg swaylock-fprintd swayidle
      kanshi i3status swaywsr mako rofi
      polkit-sway
      fooster-backgrounds colloid-gtk-theme-sway catppuccin-cursors-sway papirus-icon-theme sway-default-icon-theme
      qt6.qtsvg qt6.qtwayland
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
      export XDG_SESSION_DESKTOP=sway
      export DCONF_PROFILE=sway
    '';
  };

  programs.swayidle = {
    enable = true;
    events = [
      { event = "before-sleep"; command = "${lib.getExe' pkgs.systemd "loginctl"} lock-session"; }
      { event = "lock"; command = "${lib.getExe pkgs.swaylock-fprintd} -p -f -c 000000 --bs-hl-color 333333 --caps-lock-bs-hl-color 333333 --caps-lock-key-hl-color 333333 --font 'monospace' --font-size ${toString config.system.devices.monitorFontSize} --inside-color 222222 --inside-clear-color 222222 --inside-caps-lock-color 222222 --inside-ver-color 333333 --inside-wrong-color 222222 --key-hl-color f29bd4 --line-color 222222 --ring-color 222222 --ring-clear-color 333333 --ring-caps-lock-color 222222 --ring-ver-color 333333 --ring-wrong-color aa4444 --separator-color 222222 --text-color f29bd4 --text-clear-color f29bd4 --text-caps-lock-color f29bd4 --text-ver-color f29bd4 --text-wrong-color f29bd4"; }
      { event = "unlock"; command = "${lib.getExe' pkgs.procps "pkill"} --session \"$XDG_SESSION_ID\" -USR1 swaylock"; }
    ];
  };

  # TODO: try way-displays?
  programs.kanshi.enable = true;

  programs.mako = {
    enable = true;
    settings = {
      background-color = "#222222";
      border-size = "0";
      font = "monospace 12";
      icon-path = "${config.system.path}/share/icons/Papirus-Dark";
      margin = "12";
      progress-color = "over #333333";
      text-color = "#f29bd4";
    };
  };

  programs.sway-assign-cgroups.enable = true;

  programs.swaywsr = {
    enable = true;
    settings = {
      icons = {
        "org.qutebrowser.qutebrowser" = "#";
        "firefox" = "#";
        "chromium-browser" = "#";
        "Alacritty" = ">";
        "Element" = "@";
        "WebCord" = "@";
      };

      aliases = {
        "org.qutebrowser.qutebrowser" = "web";
        "chromium-browser" = "chromium";
        "Alacritty" = "term";
        "Element" = "chat";
        "WebCord" = "discord";
      };

      general = {
        default_icon = "*";
        separator = " | ";
      };

      options = {
        remove_duplicates = true;
      };
    };
  };

  programs.swaynag-battery = lib.mkIf (config.system.devices.batteryId != null) {
    enable = true;
    powerSupply = "BAT${toString config.system.devices.batteryId}";
  };

  preservation.preserveAt = lib.mkIf (config.preservation.enable && (config.users.users.lily.enable or false)) {
    ${config.system.devices.preservedState} = {
      users.lily = {
        directories = [
          ".backgrounds"
          ".config/qutebrowser"
          ".local/share/qutebrowser"
        ];
      };
    };
  };
}
