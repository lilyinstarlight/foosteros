{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.mopidy-user;

  mopidyConf = pkgs.writeText "mopidy.conf" cfg.configuration;

  mopidyEnv = pkgs.buildEnv {
    name = "mopidy-with-extensions-${pkgs.mopidy.version}";
    paths = closePropagation cfg.extensionPackages;
    pathsToLink = [ "/${pkgs.mopidyPackages.python.sitePackages}" ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      makeWrapper ${pkgs.mopidy}/bin/mopidy $out/bin/mopidy \
        --prefix PYTHONPATH : $out/${pkgs.mopidyPackages.python.sitePackages}
    '';
  };
in {
  options = {
    services.mopidy-user = {
      enable = mkEnableOption "Mopidy, a music player daemon";

      extensionPackages = mkOption {
        default = [];
        type = types.listOf types.package;
        example = literalExample "[ pkgs.mopidy-spotify ]";
        description = ''
          Mopidy extensions that should be loaded by the service.
        '';
      };

      configuration = mkOption {
        default = "";
        type = types.lines;
        description = ''
          The configuration that Mopidy should use.
        '';
      };

      extraConfigFiles = mkOption {
        default = [];
        type = types.listOf types.str;
        description = ''
          Extra config file read by Mopidy when the service starts.
          Later files in the list overrides earlier configuration.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.mopidy = {
      wantedBy = [ "default.target" ];
      after = [ "network.target" "sound.target" ];
      description = "mopidy music player daemon";
      serviceConfig = {
        ExecStart = "${mopidyEnv}/bin/mopidy --config ${concatStringsSep ":" ([mopidyConf] ++ cfg.extraConfigFiles)}";
      };
    };

    systemd.user.services.mopidy-scan = {
      description = "mopidy local files scanner";
      serviceConfig = {
        ExecStart = "${mopidyEnv}/bin/mopidy --config ${concatStringsSep ":" ([mopidyConf] ++ cfg.extraConfigFiles)} local scan";
        Type = "oneshot";
      };
    };
  };
}
