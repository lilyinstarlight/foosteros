{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.dnsimple-ddns;
in

{
  options.services.dnsimple-ddns = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable service for dnsimple-ddns.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.dnsimple-ddns;
      defaultText = "pkgs.dnsimple-ddns";
      description = ''
        dnsimple-ddns derivation to use.
      '';
    };

    interval = mkOption {
      type = types.str;
      default = "hourly";
      description = ''
        Interval to send log digest.
      '';
    };

    config = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = ''
        token='0123456789abcdefghijklmnopqrstuv'
        account=1010
        zone='example.com'
        arecord=5
        aaaarecord=6

        ifip=false
      '';
      description = ''
        Basic configuration for logmail.
      '';
    };

    configFile = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.config == null || cfg.configFile == null;
        message = "Only one of `config` or `configFile` may be used at a time.";
      }
    ];

    environment.etc."default/ddns" = if (cfg.configFile != null) then {
      source = cfg.configFile;
    } else {
      text = cfg.config;
    };

    systemd.services.dnsimple-ddns = {
      description = "Update dynamic DNS address";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${cfg.package}/bin/ddns";
      };
    };

    systemd.timers.dnsimple-ddns = {
      description = "Update dynamic DNS address";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.interval;
      };
    };

    environment.systemPackages = [ cfg.package ];
  };
}
