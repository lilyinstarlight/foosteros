{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.swaynag-battery;
in

{
  options.services.swaynag-battery = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable a user service for swaynag-battery.
      '';
    };

    install = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to install a user service for swaynag-battery.

        The service must be manually started for each user with
        "systemctl --user start swaynag-battery" or globally through
        <varname>services.swaynag-battery.enable</varname>.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.swaynag-battery;
      defaultText = "pkgs.swaynag-battery";
      description = ''
        swaynag-battery derivation to use.
      '';
    };

    threshold = mkOption {
      type = types.ints.unsigned;
      default = 12;
      description = ''
        Percentage threshold to show notification.
      '';
    };

    interval = mkOption {
      type = types.str;
      default = "1m";
      description = ''
        Interval to check battery stats.
      '';
    };

    powerSupply = mkOption {
      type = types.str;
      default = "BAT0";
      description = ''
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
      wantedBy = [ "sway-session.target" ];
    };

    environment.systemPackages = [ cfg.package ];
  };
}
