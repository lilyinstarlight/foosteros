{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.programs.mako;
in

{
  options.programs.mako = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable a user service for mako.
      '';
    };

    install = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to install a user service for mako.

        The service must be manually started for each user with
        "systemctl --user start mako" or globally through
        <varname>programs.mako.enable</varname>.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.mako;
      defaultText = "pkgs.mako";
      description = ''
        mako derivation to use.
      '';
    };

    targets = mkOption {
      type = types.listOf types.str;
      default = [ "sway-session.target" ];
      description = ''
        Systemd user targets to enable mako for.
      '';
    };

    extraConfig = mkOption {
      type = types.str;
      default = "";
      description = ''
        Extra configuration for mako.
      '';
    };
  };

  config = mkIf (cfg.enable || cfg.install) {
    environment.etc."mako/config".text = cfg.extraConfig;

    systemd.user.services.mako = {
      description = "Wayland notification daemon";
      partOf = [ "graphical-session.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = pkgs.writeScript "mako" ''
          #!/bin/sh
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
            exec ${cfg.package}/bin/mako --config "$makoconfig"
          else
            exec ${pkgs.mako}/bin/mako
          fi
        '';
      };
    } // optionalAttrs cfg.enable {
      wantedBy = cfg.targets;
    };
  };
}
