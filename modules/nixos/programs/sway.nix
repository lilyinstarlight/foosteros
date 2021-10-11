{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.programs.sway;
in

{
  config = mkIf cfg.enable {
    environment.etc."sway/config".text = lib.mkDefault ''
      ### systemd integration
      exec "systemctl --user import-environment XDG_SESSION_DESKTOP XDG_CURRENT_DESKTOP XDG_SESSION_TYPE DISPLAY WAYLAND_DISPLAY SWAYSOCK"
      exec "command -v dbus-update-activation-environment >/dev/null 2>&1 && dbus-update-activation-environment --systemd XDG_SESSION_DESKTOP XDG_CURRENT_DESKTOP XDG_SESSION_TYPE DISPLAY WAYLAND_DISPLAY SWAYSOCK"
      exec "systemctl --user start sway-session.target"

      include /etc/sway/config.d/*
    '';

    systemd.user.targets.sway-session = {
      unitConfig = {
        Description = "sway compositor session";
        Documentation = "man:systemd.special(7)";
        BindsTo = "graphical-session.target";
        Wants = "graphical-session-pre.target";
        After = "graphical-session-pre.target";
      };
    };
  };
}
