{ config, lib, pkgs, fpkgs ? pkgs, ... }:

let
  cfg = config.programs.tkey-fido;
in

{
  meta.maintainers = with lib.maintainers; [ /*lilyinstarlight*/ ];

  options.programs.tkey-fido = {
    enable = lib.mkEnableOption "user service for tkey-fido";

    install = lib.mkEnableOption "user service for tkey-fido" // {
      description = ''
        Whether to install a user service for tkey-fido.

        The service must be manually started for each user with
        `systemctl --user start tkey-fido` or globally through
        {option}`programs.tkey-fido.enable`.
      '';
    };

    package = lib.mkPackageOption fpkgs "tkey-fido" {
      pkgsText = "fpkgs";
    };

    port = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Serial port device path for TKey.
      '';
    };

    userSuppliedSecret = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable typing a User Supplied Secret for U2F/FIDO keys.
      '';
    };
  };

  config = lib.mkIf (cfg.enable || cfg.install) {
    hardware.uhid.enable = true;

    systemd.user.services.tkey-fido = {
      description = "TKey U2F/FIDO";
      partOf = [ "default.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe cfg.package} ${lib.optionalString cfg.userSuppliedSecret "--uss ${lib.optionalString (config.programs.gnupg.agent.settings ? pinentry-program) "--pinentry ${config.programs.gnupg.agent.settings.pinentry-program}"}"} ${lib.optionalString (cfg.port != null) "--port ${cfg.port}"}";
      };
    } // lib.optionalAttrs cfg.enable {
      wantedBy = [ "default.target" ];
    };

    environment.systemPackages = [ cfg.package ];
  };
}
