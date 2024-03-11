{ config, lib, pkgs, ... }:

let
  cfg = config.programs.sway-assign-cgroups;
in

{
  meta.maintainers = with lib.maintainers; [ lilyinstarlight ];

  options.programs.sway-assign-cgroups = {
    enable = lib.mkEnableOption "user service for sway-assign-cgroups";

    install = lib.mkEnableOption "user service for sway-assign-cgroups" // {
      description = ''
        Whether to install a user service for sway-assign-cgroups.

        The service must be manually started for each user with
        `systemctl --user start sway-assign-cgroups` or globally through
        {option}`programs.sway-assign-cgroups.enable`.
      '';
    };

    package = lib.mkPackageOption pkgs "sway-assign-cgroups" {};

    targets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "wlr-session.target" ];
      description = ''
        Systemd user targets to enable sway-assign-cgroups for.
      '';
    };
  };

  config = lib.mkIf (cfg.enable || cfg.install) {
    systemd.user.services.sway-assign-cgroups = {
      description = "Sway automatic cgroup assignment";
      partOf = [ "graphical-session.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = lib.getExe' pkgs.sway-assign-cgroups "assign-cgroups.py";
      };
    } // lib.optionalAttrs cfg.enable {
      wantedBy = cfg.targets;
    };

    environment.systemPackages = [ cfg.package ];
  };
}
