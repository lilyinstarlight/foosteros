{ config, lib, pkgs, ... }:

let
  cfg = config.programs.swaynag-battery;
in

{
  options.programs.swaynag-battery = {
    enable = lib.mkEnableOption "user service for swaynag-battery";

    install = lib.mkEnableOption "user service for swaynag-battery" // {
      description = ''
        Whether to install a user service for swaynag-battery.

        The service must be manually started for each user with
        `systemctl --user start swaynag-battery` or globally through
        {option}`programs.swaynag-battery.enable`.
      '';
    };

    package = lib.mkPackageOption pkgs "swaynag-battery" {};

    targets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "wlr-session.target" ];
      description = ''
        Systemd user targets to enable swaynag-battery for.
      '';
    };

    threshold = lib.mkOption {
      type = lib.types.ints.unsigned;
      default = 12;
      description = ''
        Percentage threshold to show notification.
      '';
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "1m";
      description = ''
        Interval to check battery stats.
      '';
    };

    powerSupply = lib.mkOption {
      type = lib.types.str;
      default = "BAT0";
      description = ''
        Power supply to read battery stats from.
      '';
    };
  };

  config = lib.mkIf (cfg.enable || cfg.install) {
    systemd.user.services.swaynag-battery = {
      description = "Low battery notification";
      partOf = [ "graphical-session.target" ];

      path = [ config.programs.sway.package ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe cfg.package} --threshold ${toString cfg.threshold} --interval ${cfg.interval} --uevent /sys/class/power_supply/${cfg.powerSupply}/uevent";
      };
    } // lib.optionalAttrs cfg.enable {
      wantedBy = cfg.targets;
    };

    environment.systemPackages = [ cfg.package ];
  };
}
