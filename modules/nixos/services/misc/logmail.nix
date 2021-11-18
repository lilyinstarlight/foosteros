{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.logmail;
in

{
  options.services.logmail = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable service for logmail.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.logmail;
      defaultText = "pkgs.logmail";
      description = ''
        logmail derivation to use.
      '';
    };

    interval = mkOption {
      type = types.str;
      default = "hourly";
      description = ''
        Interval to send log digest.
      '';
    };

    timespan = mkOption {
      type = types.str;
      default = "-1h";
      description = ''
        Time span of logs to digest.
      '';
    };

    filter = mkOption {
      type = types.lines;
      default = "";
      example = ''
        systemd\[[0-9]*\]: Failed to start Mark boot as successful.
      '';
      description = ''
        Filter of items to remove from digests
      '';
    };

    config = mkOption {
      type = types.str;
      default = "";
      example = ''
        mailfrom="logs@example.com"
        mailto="logs@example.com"
        subject="Logs for $(hostname) at $(date +"%F %R")"
      '';
      description = ''
        Basic configuration for logmail.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.etc.logfilter.text = cfg.filter;

    environment.etc."default/logmail".text = cfg.config;

    systemd.services.logmail = {
      description = "Email logged errors and failed units from the last hour";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${cfg.package}/bin/logmail ${cfg.timespan} err /etc/logfilter";
      };
    };

    systemd.timers.logmail = {
      description = "Email logged errors and failed units from the last hour";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.interval;
      };
    };

    environment.systemPackages = [ cfg.package ];
  };
}
