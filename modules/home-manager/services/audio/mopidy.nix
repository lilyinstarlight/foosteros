{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.mopidy;

  iniFormat = pkgs.formats.ini {};

  mopidyEnv = pkgs.buildEnv {
    name = "mopidy-with-extensions-${cfg.package.version}";
    paths = closePropagation cfg.extensionPackages;
    pathsToLink = [ "/${pkgs.mopidyPackages.python.sitePackages}" ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      makeWrapper ${cfg.package}/bin/mopidy $out/bin/mopidy \
        --prefix PYTHONPATH : $out/${pkgs.mopidyPackages.python.sitePackages}
    '';
  };
in {
  options.services.mopidy = {
    enable = mkEnableOption "Mopidy, a music player daemon";

    package = mkOption {
      type = types.package;
      default = pkgs.mopidy;
      defaultText = literalExpression "pkgs.mopidy";
      description = "The Mopidy package to use.";
    };

    extensionPackages = mkOption {
      default = [];
      type = types.listOf types.package;
      example = literalExpression "[ pkgs.mopidy-spotify ]";
      description = ''
        Mopidy extensions that should be loaded by the service.
      '';
    };

    settings = mkOption {
      type = iniFormat.type;
      default = {};
      description = ''
        Configuration written to
        <filename>~/.config/mopidy/mopidy.conf</filename>
      '';
    };

    extraConfigFiles = mkOption {
      default = [];
      type = types.listOf types.str;
      description = ''
        Extra config file read by Mopidy when the service starts.
        Later files in the list overrides earlier configuration
        and structured settings.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.mopidy = {
      Install = { WantedBy = [ "default.target" ]; };

      Unit = {
        Description = "Mopidy music player daemon";
        After = [ "network.target" "sound.target" ];
      };

      Service = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "5s";
        ExecStart = "${mopidyEnv}/bin/mopidy --config ${concatStringsSep ":" (["${config.xdg.configHome}/mopidy/mopidy.conf"] ++ cfg.extraConfigFiles)}";
      };
    };

    systemd.user.services.mopidy-scan = {
      Unit = {
        Description = "Mopidy local files scanner";
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${mopidyEnv}/bin/mopidy --config ${concatStringsSep ":" (["${config.xdg.configHome}/mopidy/mopidy.conf"] ++ cfg.extraConfigFiles)} local scan";
      };
    };

    xdg.configFile."mopidy/mopidy.conf".source = iniFormat.generate "mopidy.conf" cfg.settings;
  };
}
