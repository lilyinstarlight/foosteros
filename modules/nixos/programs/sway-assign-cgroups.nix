{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.sway-assign-cgroups;
in

{
  options.programs.sway-assign-cgroups = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc ''
        Whether to enable a user service for sway-assign-cgroups.
      '';
    };

    install = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc ''
        Whether to install a user service for sway-assign-cgroups.

        The service must be manually started for each user with
        `systemctl --user start sway-assign-cgroups` or globally through
        {option}`programs.sway-assign-cgroups.enable`.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.sway-assign-cgroups;
      defaultText = literalExpression "pkgs.sway-assign-cgroups";
      description = mdDoc ''
        sway-assign-cgroups derivation to use.
      '';
    };
  };

  config = mkIf (cfg.enable || cfg.install) {
    systemd.user.services.sway-assign-cgroups = {
      description = "Sway automatic cgroup assignment";
      partOf = [ "graphical-session.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = lib.getExe' pkgs.sway-assign-cgroups "assign-cgroups.py";
      };
    } // optionalAttrs cfg.enable {
      wantedBy = [ "wlr-session.target" ];
    };

    environment.systemPackages = [ cfg.package ];
  };
}
