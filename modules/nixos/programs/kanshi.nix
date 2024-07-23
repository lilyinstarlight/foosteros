{ config, pkgs, lib, ... }:

let
  cfg = config.programs.kanshi;

  mkProfile = name: profile: ''
    profile ${name} {
    ${lib.concatLines (
      (lib.mapAttrsToList (output: options: "  output \"${output}\" ${options}") profile.outputs)
      ++ (map (command: "  exec ${command}") profile.commands)
    )}
    }
  '';

  profileModule = { ... }: {
    options = {
      outputs = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        example = {
          "eDP-1" = "enable mode 2256x1504 position 0,0 scale 1.5";
        };
        description = "Outputs to configure.";
      };

      commands = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = lib.literalExpression ''
          [
            "''${lib.getExe' pkgs.sway "swaymsg"} workspace number 1, move workspace to eDP-1"
          ]
        '';
        description = "Commands to run when switching to output.";
      };
    };
  };
in

{
  meta.maintainers = with lib.maintainers; [ /*lilyinstarlight*/ ];

  options.programs.kanshi = {
    enable = lib.mkEnableOption "user service for kanshi";

    install = lib.mkEnableOption "user service for kanshi" // {
      description = ''
        Whether to install a user service for kanshi.

        The service must be manually started for each user with
        `systemctl --user start kanshi` or globally through
        {option}`programs.kanshi.enable`.
      '';
    };

    package = lib.mkPackageOption pkgs "kanshi" {};

    targets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "wlr-session.target" ];
      description = ''
        Systemd user targets to enable kanshi for.
      '';
    };

    profiles = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule profileModule);
      default = {};
      description = ''
        Profiles for kanshi.
      '';
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Extra configurations for kanshi.
      '';
    };
  };

  config = lib.mkIf (cfg.enable || cfg.install) {
    environment.etc."kanshi/config".text = ''
      ${lib.concatLines (lib.mapAttrsToList mkProfile cfg.profiles)}
      ${cfg.extraConfig}
    '';

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
          exec ${lib.getExe cfg.package} --config "$kanshiconfig"
        else
          exec ${lib.getExe cfg.package}
        fi
      '';

      serviceConfig.Type = "simple";
    } // lib.optionalAttrs cfg.enable {
      wantedBy = cfg.targets;
    };
  };
}
