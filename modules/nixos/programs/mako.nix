{ config, pkgs, lib, ... }:

let
  cfg = config.programs.mako;
in

{
  options.programs.mako = {
    enable = lib.mkEnableOption "user service for mako";

    install = lib.mkEnableOption "user service for mako" // {
      description = ''
        Whether to install a user service for mako.

        The service must be manually started for each user with
        `systemctl --user start mako` or globally through
        {option}`programs.mako.enable`.
      '';
    };

    package = lib.mkPackageOption pkgs "mako" {};

    targets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "wlr-session.target" ];
      description = ''
        Systemd user targets to enable mako for.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf (lib.types.oneOf [ lib.types.str lib.types.int ]);
      default = {};
      description = ''
        Configuration for mako.
      '';
    };
  };

  config = lib.mkIf (cfg.enable || cfg.install) {
    environment.etc."mako/config".text = lib.concatLines (lib.mapAttrsToList (name: value: "${name}=${value}") cfg.settings);

    systemd.user.services.mako = {
      description = "Wayland notification daemon";
      partOf = [ "graphical-session.target" ];

      script = ''
        makoconfig=""

        if [ -z "$XDG_CONFIG_HOME" ]; then
          XDG_CONFIG_HOME="$HOME/.config"
        fi

        if [ -f "$HOME"/.mako/config ]; then
          makoconfig="$HOME/.mako/config"
        elif [ -f "$XDG_CONFIG_HOME"/mako/config ]; then
          makoconfig="$XDG_CONFIG_HOME/mako/config"
        elif [ -f /etc/xdg/mako/config ]; then
          makoconfig="/etc/xdg/mako/config"
        elif [ -f /etc/mako/config ]; then
          makoconfig="/etc/mako/config"
        fi

        if [ -n "$makoconfig" ]; then
          exec ${lib.getExe cfg.package} --config "$makoconfig"
        else
          exec ${lib.getExe cfg.package}
        fi
      '';

      serviceConfig = {
        Type = "dbus";
        BusName = "org.freedesktop.Notifications";
      };
    } // lib.optionalAttrs cfg.enable {
      wantedBy = cfg.targets;
    };
  };
}
