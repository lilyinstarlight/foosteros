{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.swaywsr;
in

{
  options.programs.swaywsr = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc ''
        Whether to enable a user service for swaywsr.
      '';
    };

    install = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc ''
        Whether to install a user service for swaywsr.

        The service must be manually started for each user with
        `systemctl --user start swaywsr` or globally through
        {option}`services.swaywsr.enable`.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.swaywsr;
      defaultText = literalExpression "pkgs.swaywsr";
      description = mdDoc ''
        swaywsr derivation to use.
      '';
    };

    extraConfig = mkOption {
      type = types.str;
      default = "";
      description = mdDoc ''
        Extra configuration for swaywsr.
      '';
    };
  };

  config = mkIf (cfg.enable || cfg.install) {
    environment.etc."swaywsr/config.toml".text = cfg.extraConfig;

    systemd.user.services.swaywsr = {
      description = "Sway workspace renamer";
      partOf = [ "graphical-session.target" ];

      script = ''
        swaywsrconfig=""

        if [ -z "$XDG_CONFIG_HOME" ]; then
          XDG_CONFIG_HOME="$HOME/.config"
        fi

        if [ -f "$HOME"/.swaywsr/config.toml ]; then
          swaywsrconfig="$HOME/.swaywsr/config.toml"
        elif [ -f "$XDG_CONFIG_HOME"/swaywsr/config.toml ]; then
          swaywsrconfig="$XDG_CONFIG_HOME/swaywsr/config.toml"
        elif [ -f /etc/xdg/swaywsr/config.toml ]; then
          swaywsrconfig="/etc/xdg/swaywsr/config.toml"
        elif [ -f /etc/swaywsr/config.toml ]; then
          swaywsrconfig="/etc/swaywsr/config.toml"
        fi

        if [ -n "$swaywsrconfig" ]; then
          exec ${cfg.package}/bin/swaywsr --config "$swaywsrconfig"
        else
          exec ${cfg.package}/bin/swaywsr
        fi
      '';

      serviceConfig.Type = "simple";
    } // optionalAttrs cfg.enable {
      wantedBy = [ "wlr-session.target" ];
    };

    environment.systemPackages = [ cfg.package ];
  };
}
