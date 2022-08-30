{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.swaynag-battery;
in

{
  options.programs.swaynag-battery = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc ''
        Whether to enable a user service for swaynag-battery.
      '';
    };

    install = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc ''
        Whether to install a user service for swaynag-battery.

        The service must be manually started for each user with
        `systemctl --user start swaynag-battery` or globally through
        {option}`programs.swaynag-battery.enable`.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.swaynag-battery;
      defaultText = literalExpression "pkgs.swaynag-battery";
      description = mdDoc ''
        swaynag-battery derivation to use.
      '';
    };

    threshold = mkOption {
      type = types.ints.unsigned;
      default = 12;
      description = mdDoc ''
        Percentage threshold to show notification.
      '';
    };

    interval = mkOption {
      type = types.str;
      default = "1m";
      description = mdDoc ''
        Interval to check battery stats.
      '';
    };

    powerSupply = mkOption {
      type = types.str;
      default = "BAT0";
      description = mdDoc ''
        Power supply to read battery stats from.
      '';
    };
  };

  config = mkIf (cfg.enable || cfg.install) {
    systemd.user.services.swaynag-battery = {
      description = "Low battery notification";
      partOf = [ "graphical-session.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/swaynag-battery --threshold ${toString cfg.threshold} --interval ${cfg.interval} --uevent /sys/class/power_supply/${cfg.powerSupply}/uevent";
      };
    } // optionalAttrs cfg.enable {
      wantedBy = [ "wlr-session.target" ];
    };

    environment.systemPackages = [ cfg.package ];
  };
}
