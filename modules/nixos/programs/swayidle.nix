{ config, lib, pkgs, ... }:

let
  cfg = config.programs.swayidle;

  mkTimeout = entry:
    "timeout ${toString entry.timeout} ${lib.escapeShellArg entry.command}"
      + lib.optionalString (entry.resumeCommand != null)
        "resume ${lib.escapeShellArg entry.resumeCommand}";
  mkEvent = entry: "${entry.event} ${lib.escapeShellArg entry.command}";
  mkIdleHint = timeout: "idlehint ${toString timeout}";

  timeoutModule = { ... }: {
    options = {
      timeout = lib.mkOption {
        type = lib.types.ints.positive;
        example = 60;
        description = "Timeout in seconds.";
      };

      command = lib.mkOption {
        type = lib.types.str;
        description = "Command to run after inactivity timeout.";
      };

      resumeCommand = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Command to run when there is activity again.";
      };
    };
  };

  eventModule = { ... }: {
    options = {
      event = lib.mkOption {
        type = lib.types.enum [ "before-sleep" "after-resume" "lock" "unlock" ];
        description = "Event name.";
      };

      command = lib.mkOption {
        type = lib.types.str;
        description = "Command to run when event occurs.";
      };
    };
  };

  swayIdleConfig = lib.concatMapStrings (s: s + "\n") (
    (map mkTimeout cfg.timeouts)
    ++ (map mkEvent cfg.events)
    ++ (lib.optional (cfg.idleHint != null) (mkIdleHint cfg.idleHint))
  );
in

{
  options.programs.swayidle = {
    enable = lib.mkEnableOption "user service for swayidle";

    install = lib.mkEnableOption "user service for swayidle" // {
      description = ''
        Whether to install a user service for swayidle.

        The service must be manually started for each user with
        `systemctl --user start swayidle` or globally through
        {option}`programs.swayidle.enable`.
      '';
    };

    package = lib.mkPackageOption pkgs "swayidle" {};

    targets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "wlr-session.target" ];
      description = ''
        Systemd user targets to enable swayidle for.
      '';
    };

    timeouts = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule timeoutModule);
      default = [];
      example = lib.literalExpression ''
        [
          { timeout = 60; command = "''${lib.getExe pkgs.swaylock} -fF"; }
        ]
      '';
      description = "List of commands to run after inactivity timeout.";
    };

    events = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule eventModule);
      default = [];
      example = lib.literalExpression ''
        [
          { event = "before-sleep"; command = "''${lib.getExe pkgs.swaylock}"; }
          { event = "lock"; command = "lock"; }
        ]
      '';
      description = "Run command on occurrence of a event.";
    };

    idleHint = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = null;
      example = 60;
      description = "Timeout in seconds to set logind IdleHint.";
    };
  };

  config = lib.mkIf (cfg.enable || cfg.install) {
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

        exec ${lib.getExe cfg.package} -w -C "$swayidleconfig" -S "$XDG_SEAT"
      '';

      serviceConfig.Type = "simple";
    } // lib.optionalAttrs cfg.enable {
      wantedBy = cfg.targets;
    };

    environment.systemPackages = [ cfg.package ];
  };
}
