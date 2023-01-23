{ config, pkgs, lib, ... }:

with lib;

{
  options.system.devices = {
    rootDisk = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc ''
        Disk device path to use for root filesystem.
      '';
    };

    coreThermalZone = mkOption {
      type = types.nullOr types.ints.unsigned;
      default = null;
      description = mdDoc ''
        Primary core temperature to use for configuring status bars and system services.
      '';
    };

    batteryId = mkOption {
      type = types.nullOr types.ints.unsigned;
      default = null;
      description = mdDoc ''
        Primary battery to use for configuring status bars and system services.
      '';
    };

    wirelessAdapter = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc ''
        Primary wireless adapter to use for configuring status bars and system services.
      '';
    };

    backupAdapter = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc ''
        Primary adapter to check for backups, to prevent backing up on metered connections.
      '';
    };

    auxiliary = mkOption {
      type = types.submoduleWith {
        modules = [{
          freeformType = with types; lazyAttrsOf (uniq unspecified);
        }];
      };
      default = {};
      description = mdDoc ''
        Attribute set of auxiliary options for certain hosts to store configurable devices in.
      '';
    };
  };
}
