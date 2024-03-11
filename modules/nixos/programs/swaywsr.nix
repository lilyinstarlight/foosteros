{ config, lib, pkgs, ... }:

let
  cfg = config.programs.swaywsr;
  format = pkgs.formats.toml {};
in

{
  meta.maintainers = with lib.maintainers; [ lilyinstarlight ];

  options.programs.swaywsr = {
    enable = lib.mkEnableOption "user service for swaywsr";

    install = lib.mkEnableOption "user service for swaywsr" // {
      description = ''
        Whether to install a user service for swaywsr.

        The service must be manually started for each user with
        `systemctl --user start swaywsr` or globally through
        {option}`programs.swaywsr.enable`.
      '';
    };

    package = lib.mkPackageOption pkgs "swaywsr" {};

    targets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "wlr-session.target" ];
      description = ''
        Systemd user targets to enable swaywsr for.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf format.type;
      default = {};
      description = ''
        Configuration for swaywsr.
      '';
    };
  };

  config = lib.mkIf (cfg.enable || cfg.install) {
    environment.etc."swaywsr/config.toml".source = format.generate "config.toml" cfg.settings;

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
          exec ${lib.getExe' cfg.package "swaywsr"} --config "$swaywsrconfig"
        else
          exec ${lib.getExe' cfg.package "swaywsr"}
        fi
      '';

      serviceConfig.Type = "simple";
    } // lib.optionalAttrs cfg.enable {
      wantedBy = cfg.targets;
    };

    environment.systemPackages = [ cfg.package ];
  };
}
