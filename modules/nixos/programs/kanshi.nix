{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.programs.kanshi;
in

{
  options.programs.kanshi = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc ''
        Whether to enable a user service for kanshi.
      '';
    };

    install = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc ''
        Whether to install a user service for kanshi.

        The service must be manually started for each user with
        `systemctl --user start kanshi` or globally through
        {option}`programs.kanshi.enable`.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.kanshi;
      defaultText = literalExpression "pkgs.kanshi";
      description = mdDoc ''
        kanshi derivation to use.
      '';
    };

    targets = mkOption {
      type = types.listOf types.str;
      default = [ "wlr-session.target" ];
      description = mdDoc ''
        Systemd user targets to enable kanshi for.
      '';
    };

    extraConfig = mkOption {
      type = types.str;
      default = "";
      description = mdDoc ''
        Extra configuration for kanshi.
      '';
    };
  };

  config = mkIf (cfg.enable || cfg.install) {
    environment.etc."kanshi/config".text = cfg.extraConfig;

    systemd.user.services.kanshi = {
      description = "Wayland display configuration daemon";
      partOf = [ "graphical-session.target" ];

      script = ''
        kanshiconfig=""

        if [ -z "$XDG_CONFIG_HOME" ]; then
          XDG_CONFIG_HOME="$HOME/.config"
        fi

        if [ -f "$HOME"/.kanshi/config ]; then
          kanshiconfig="$HOME/.kanshi/config"
        elif [ -f "$XDG_CONFIG_HOME"/kanshi/config ]; then
          kanshiconfig="$XDG_CONFIG_HOME/kanshi/config"
        elif [ -f /etc/xdg/kanshi/config ]; then
          kanshiconfig="/etc/xdg/kanshi/config"
        elif [ -f /etc/kanshi/config ]; then
          kanshiconfig="/etc/kanshi/config"
        fi

        if [ -n "$kanshiconfig" ]; then
          exec ${cfg.package}/bin/kanshi --config "$kanshiconfig"
        else
          exec ${cfg.package}/bin/kanshi
        fi
      '';

      serviceConfig.Type = "simple";
    } // optionalAttrs cfg.enable {
      wantedBy = cfg.targets;
    };
  };
}
