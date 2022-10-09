{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.programs.sway;
in

{
  config = mkIf cfg.enable {
    environment.etc."sway/config".text = lib.mkDefault ''
      ### systemd integration
      exec "systemctl --user import-environment XDG_SESSION_CLASS XDG_CONFIG_DIRS XDG_DATA_DIRS XDG_SESSION_DESKTOP XDG_CURRENT_DESKTOP XDG_SESSION_TYPE DCONF_PROFILE XDG_DESKTOP_PORTAL_DIR DISPLAY WAYLAND_DISPLAY SWAYSOCK XMODIFIERS XCURSOR_SIZE XCURSOR_THEME GDK_PIXBUF_MODULE_FILE GIO_EXTRA_MODULES GTK_IM_MODULE QT_PLUGIN_PATH QT_QPA_PLATFORMTHEME QT_STYLE_OVERRIDE QT_IM_MODULE NIXOS_OZONE_WL"
      exec "command -v dbus-update-activation-environment >/dev/null 2>&1 && dbus-update-activation-environment --systemd XDG_SESSION_CLASS XDG_CONFIG_DIRS XDG_DATA_DIRS XDG_SESSION_DESKTOP XDG_CURRENT_DESKTOP XDG_SESSION_TYPE DCONF_PROFILE XDG_DESKTOP_PORTAL_DIR DISPLAY WAYLAND_DISPLAY SWAYSOCK XMODIFIERS XCURSOR_SIZE XCURSOR_THEME GDK_PIXBUF_MODULE_FILE GIO_EXTRA_MODULES GTK_IM_MODULE QT_PLUGIN_PATH QT_QPA_PLATFORMTHEME QT_STYLE_OVERRIDE QT_IM_MODULE NIXOS_OZONE_WL"
      exec "systemctl --user restart wlr-session.target"

      include /etc/sway/config.d/*
    '';

    systemd.user.targets.wlr-session = {
      description = "wlroots compositor session";

      bindsTo = [ "graphical-session.target" ];
      wants = [ "graphical-session-pre.target" "xdg-desktop-autostart.target" ];
      after = [ "graphical-session-pre.target" ];
      before = [ "xdg-desktop-autostart.target" ];
    };
  };
}
