{ config, pkgs, lib, ... }:

{
  meta.maintainers = with lib.maintainers; [ /*lilyinstarlight*/ ];

  options.system.devices = {
    rootDisk = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Disk device path to use for root filesystem.
      '';
    };

    coreThermalZone = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.unsigned;
      default = null;
      description = ''
        Primary core temperature to use for configuring status bars and system services.
      '';
    };

    batteryId = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.unsigned;
      default = null;
      description = ''
        Primary battery to use for configuring status bars and system services.
      '';
    };

    wirelessAdapter = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Primary wireless adapter to use for configuring status bars and system services.
      '';
    };

    backupAdapter = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Primary adapter to check for backups, to prevent backing up on metered connections.
      '';
    };

    monitorFontSize = lib.mkOption {
      type = lib.types.ints.positive;
      default = 16;
      description = ''
        What font size is appropriate for the monitor, such as for console fonts or desktop environment config.
      '';
    };

    auxiliary = lib.mkOption {
      type = lib.types.submoduleWith {
        modules = [{
          freeformType = lib.types.lazyAttrsOf (lib.types.uniq lib.types.unspecified);
        }];
      };
      default = {};
      description = ''
        Attribute set of auxiliary options for certain hosts to store configurable devices in.
      '';
    };
  };
}
