{ config, lib, pkgs, fpkgs ? pkgs, ... }:

let
  cfg = config.services.logmail;
in

{
  options.services.logmail = {
    enable = lib.mkEnableOption "logmail service";

    package = lib.mkPackageOption fpkgs "logmail" {
      pkgsText = "fpkgs";
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "hourly";
      description = ''
        Interval to send log digest.
      '';
    };

    timespan = lib.mkOption {
      type = lib.types.str;
      default = "-1h";
      description = ''
        Time span of logs to digest.
      '';
    };

    filter = lib.mkOption {
      type = lib.types.lines;
      default = "";
      example = ''
        systemd\[[0-9]*\]: Failed to start Mark boot as successful.
      '';
      description = ''
        Filter of items to remove from digests
      '';
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = {
        mailfrom = "logs@example.com";
        mailto = "logs@example.com";
        subject = "Logs for host at %F %R";
      };
      description = ''
        Basic configuration for logmail.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc.logfilter.text = cfg.filter;

    environment.etc."default/logmail".text = lib.toShellVars cfg.settings;

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
