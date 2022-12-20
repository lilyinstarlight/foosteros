{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.swayidle;

  mkTimeout = entry:
    "timeout ${toString entry.timeout} ${escapeShellArg entry.command}"
      + optionalString (entry.resumeCommand != null)
        "resume ${escapeShellArg entry.resumeCommand}";
  mkEvent = entry: "${entry.event} ${escapeShellArg entry.command}";
  mkIdleHint = timeout: "idlehint ${toString timeout}";

  timeoutModule = { ... }: {
    options = {
      timeout = mkOption {
        type = types.ints.positive;
        example = 60;
        description = "Timeout in seconds.";
      };

      command = mkOption {
        type = types.str;
        description = "Command to run after inactivity timeout.";
      };

      resumeCommand = mkOption {
        type = with types; nullOr str;
        default = null;
        description = "Command to run when there is activity again.";
      };
    };
  };

  eventModule = { ... }: {
    options = {
      event = mkOption {
        type = types.enum [ "before-sleep" "after-resume" "lock" "unlock" ];
        description = "Event name.";
      };

      command = mkOption {
        type = types.str;
        description = "Command to run when event occurs.";
      };
    };
  };

  swayIdleConfig = concatMapStrings (s: s + "\n") (
    (map mkTimeout cfg.timeouts)
    ++ (map mkEvent cfg.events)
    ++ (lib.optional (cfg.idleHint != null) (mkIdleHint cfg.idleHint))
  );
in

{
  options.programs.swayidle = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc ''
        Whether to enable a user service for swayidle.
      '';
    };

    install = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc ''
        Whether to install a user service for swayidle.

        The service must be manually started for each user with
        `systemctl --user start swayidle` or globally through
        {option}`programs.swayidle.enable`.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.swayidle;
      defaultText = literalExpression "pkgs.swayidle";
      description = mdDoc ''
        swayidle derivation to use.
      '';
    };

    timeouts = mkOption {
      type = with types; listOf (submodule timeoutModule);
      default = [];
      example = literalExpression ''
        [
          { timeout = 60; command = "${pkgs.swaylock}/bin/swaylock -fF"; }
        ]
      '';
      description = "List of commands to run after inactivity timeout.";
    };

    events = mkOption {
      type = with types; listOf (submodule eventModule);
      default = [];
      example = literalExpression ''
        [
          { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock"; }
          { event = "lock"; command = "lock"; }
        ]
      '';
      description = "Run command on occurrence of a event.";
    };

    idleHint = mkOption {
      type = with types; nullOr ints.positive;
      default = null;
      example = 60;
      description = "Timeout in seconds to set logind IdleHint.";
    };
  };

  config = mkIf (cfg.enable || cfg.install) {
    environment.etc."swayidle/config".text = swayIdleConfig;

    systemd.user.services.swayidle = {
      description = "Sway idle management daemon";
      partOf = [ "graphical-session.target" ];

      script = ''
        swayidleconfig=""

        if [ -z "$XDG_CONFIG_HOME" ]; then
          XDG_CONFIG_HOME="$HOME/.config"
        fi

        if [ -z "$XDG_SEAT" ]; then
          XDG_SEAT="seat0"
        fi

        if [ -f "$HOME"/.swayidle/config ]; then
          swayidleconfig="$HOME/.swayidle/config"
        elif [ -f "$XDG_CONFIG_HOME"/swayidle/config ]; then
          swayidleconfig="$XDG_CONFIG_HOME/swayidle/config"
        elif [ -f /etc/xdg/swayidle/config ]; then
          swayidleconfig="/etc/xdg/swayidle/config"
        elif [ -f /etc/swayidle/config ]; then
          swayidleconfig="/etc/swayidle/config"
        fi

        exec ${cfg.package}/bin/swayidle -w -C "$swayidleconfig" -S "$XDG_SEAT"
      '';

      serviceConfig.Type = "simple";
    } // optionalAttrs cfg.enable {
      wantedBy = [ "wlr-session.target" ];
    };

    environment.systemPackages = [ cfg.package ];
  };
}
