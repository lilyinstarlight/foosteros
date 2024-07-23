{ config, lib, pkgs, fpkgs ? pkgs, ... }:

let
  cfg = config.services.dnsimple-ddns;
in

{
  meta.maintainers = with lib.maintainers; [ /*lilyinstarlight*/ ];

  options.services.dnsimple-ddns = {
    enable = lib.mkEnableOption "dnsimple-ddns service";

    package = lib.mkPackageOption fpkgs "dnsimple-ddns" {
      pkgsText = "fpkgs";
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "hourly";
      description = ''
        Interval to run dnsimple-ddns.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.nullOr (lib.types.attrsOf lib.types.str);
      default = null;
      example = {
        token = "0123456789abcdefghijklmnopqrstuv";
        account = "1010";
        zone = "example.com";
        arecord = "5";
        aaaarecord = "6";
        ifip = "false";
      };
      description = ''
        Basic configuration for dnsimple-ddns.
      '';
    };

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.settings == null || cfg.configFile == null;
        message = "Only one of `settings` or `configFile` may be used at a time.";
      }
    ];

    environment.etc."default/ddns" = if (cfg.configFile != null) then {
      source = cfg.configFile;
    } else {
      text = lib.toShellVars cfg.settings;
    };

    systemd.services.dnsimple-ddns = {
      description = "Update dynamic DNS address";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.getExe cfg.package;
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
