{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    qutebrowser firefox google-chrome
  ];

  fonts.fonts = with pkgs; [ monofur-nerdfont ];

  environment.etc."xdg/gtk-3.0/settings.ini".text = lib.mkDefault ''
    [Settings]
    gtk-theme-name=Arc-Dark
    gtk-icon-theme-name=Papirus
    gtk-font-name=Monofur Nerd Font 12
    gtk-cursor-theme-name=Bibata_Oil
    gtk-application-prefer-dark-theme=true
  '';

  environment.etc."xdg/gtk-2.0/gtkrc".text = lib.mkDefault ''
    gtk-theme-name="Arc-Dark"
    gtk-icon-theme-name="Papirus"
    gtk-font-name="Monofur Nerd Font 12"
    gtk-cursor-theme-name="Bibata_Oil"
  '';

  environment.etc."sway/config".text = lib.mkDefault ''
    ### variables
    set $mod mod4
    set $term alacritty
    set $run wofi --show run
    set $lock swaylock
    set $pass wofi-pass
    set $browser qutebrowser

    ### global settings
    font Monofur Nerd Font 12
    focus_follows_mouse yes
    mouse_warping output

    ### desktop settings
    default_border normal 2
    default_floating_border normal 2
    gaps inner 12

    ### color settings
    set $lock $lock -c 000000 --bshlcolor 333333 --insidecolor 222222 --insidevercolor 333333 --insidewrongcolor 222222 --keyhlcolor f29bd4 --linecolor 222222 --ringcolor 222222 --ringvercolor 333333 --ringwrongcolor aa4444 --separatorcolor 222222 --textcolor f29bd4

    client.background #f29bd4
    client.focused #333333 #333333 #f29bd4 #f29bd4 #f29bd4
    client.focused_inactive #333333 #333333 #f29bd4 #f29bd4 #996185
    client.unfocused #333333 #333333 #996185 #f29bd4 #444444
    client.urgent #f29bd4 #f29bd4 #333333 #f29bd4 #444444

    ### rules

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
    bindsym $mod+1 workspace 1:term
    bindsym $mod+2 workspace 2:www
    bindsym $mod+3 workspace 3:chat
    bindsym $mod+4 workspace 4:work
    bindsym $mod+5 workspace 5:school
    bindsym $mod+6 workspace 6:music
    bindsym $mod+7 workspace 7:games

    bindsym $mod+shift+1 move container to workspace 1:term
    bindsym $mod+shift+2 move container to workspace 2:www
    bindsym $mod+shift+3 move container to workspace 3:chat
    bindsym $mod+shift+4 move container to workspace 4:work
    bindsym $mod+shift+5 move container to workspace 5:school
    bindsym $mod+shift+6 move container to workspace 6:music
    bindsym $mod+shift+7 move container to workspace 7:games

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
    bindsym xf86monbrightnessdown exec brightnessctl -c backlight -10%
    bindsym xf86monbrightnessup exec brightnessctl -c backlight +10%
    bindsym shift+xf86monbrightnessdown exec brightnessctl -c backlight -1%
    bindsym shift+xf86monbrightnessup exec brightnessctl -c backlight +1%
    bindsym $mod+xf86monbrightnessdown exec brightnessctl -c backlight 0%
    bindsym $mod+xf86monbrightnessup exec brightnessctl -c backlight 100%

    bindsym xf86kbdbrightnessdown exec brightnessctl -c leds -10%
    bindsym xf86kbdbrightnessup exec brightnessctl -c leds +10%
    bindsym shift+xf86kbdbrightnessdown exec brightnessctl -c leds -1%
    bindsym shift+xf86kbdbrightnessup exec brightnessctl -c leds +1%
    bindsym $mod+xf86kbdbrightnessdown exec brightnessctl -c leds 0%
    bindsym $mod+xf86kbdbrightnessup exec brightnessctl -c leds 100%

    bindsym xf86audiolowervolume exec amixer -q -D pulse sset Master 10%-
    bindsym xf86audioraisevolume exec amixer -q -D pulse sset Master 10%+
    bindsym shift+xf86audiolowervolume exec amixer -q -D pulse sset Master 1%-
    bindsym shift+xf86audioraisevolume exec amixer -q -D pulse sset Master 1%+
    bindsym $mod+xf86audiolowervolume exec amixer -q -D pulse sset Master 0%
    bindsym $mod+xf86audioraisevolume exec amixer -q -D pulse sset Master 100%
    bindsym xf86audiomute exec amixer -q -D pulse sset Master toggle

    bindsym xf86audioplay exec mpc -q toggle
    bindsym xf86audiostop exec mpc -q stop
    bindsym xf86audioprev exec mpc -q prev
    bindsym xf86audionext exec mpc -q next

    #### applications
    bindsym $mod+semicolon exec $term
    bindsym $mod+return exec $run
    bindsym $mod+space exec $lock
    bindsym $mod+backslash exec $pass
    bindsym $mod+a exec $browser

    #### shortcuts
    bindsym $mod+minus exec tvup
    bindsym $mod+equal exec tvdown
    bindsym $mod+d exec mntup
    bindsym $mod+f exec mntdown
    bindsym $mod+print exec grim "$HOME"/tmp/screenshot.png
    bindsym $mod+shift+print exec grim -g "$(slurp)" "$HOME"/tmp/screenshot.png

    ### desktop elements
    bar {
        position top

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

        strip_workspace_numbers yes
        separator_symbol " • "

        status_command i3status
    }

    ### desktop services
    #exec_always xrdb -merge "$HOME"/.Xresources
    #exec_always pgrep polkit-gnome || run /usr/libexec/polkit-gnome-authentication-agent-1
    #exec_always setbg


    ### desktop environment
    exec_always gsettings set org.gnome.desktop.interface gtk-theme "Arc-Dark"
    exec_always gsettings set org.gnome.desktop.interface icon-theme "Papirus"
    exec_always gsettings set org.gnome.desktop.interface cursor-theme "Bibata_Oil"
    seat seat0 xcursor_theme "Bibata_Oil"

    include /etc/sway/config.d/*
  '';

  environment.etc."xdg/i3status/config".text = lib.mkDefault ''
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

  environment.etc."xdg/i3status/tmux".text = lib.mkDefault ''
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

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      brightnessctl jq glib
      swaylock swayidle
      i3status mako wofi alacritty
      arc-theme bibata-cursors papirus-icon-theme
      slurp grim wl-clipboard
      xwayland
    ];
    extraSessionCommands = ''
      export XDG_SESSION_TYPE=wayland
      export WLR_NO_HARDWARE_CURSORS=1
    '';
  };
}
