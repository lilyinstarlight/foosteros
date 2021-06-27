{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.mpdris2;

  toIni = generators.toINI {
    mkKeyValue = key: value:
      let
        value' = if isBool value then
          (if value then "True" else "False")
        else
          toString value;
      in "${key} = ${value'}";
  };

  mpdris2Conf = {
    Connection = {
      host = cfg.mpd.host;
      port = cfg.mpd.port;
      music_dir = cfg.mpd.musicDirectory;
    };

    Bling = {
      notify = cfg.notifications;
      mmkeys = cfg.multimediaKeys;
    };
  };

in {
  disabledModules = [ "services/mpdris2.nix" ];

  options.services.mpdris2 = {
    enable = mkEnableOption "mpDris2 the MPD to MPRIS2 bridge";
    notifications = mkEnableOption "song change notifications";
    multimediaKeys = mkEnableOption "multimedia key support";

    package = mkOption {
      type = types.package;
      default = pkgs.mpdris2;
      defaultText = literalExample "pkgs.mpdris2";
      description = "The mpDris2 package to use.";
    };

    mpd = {
      host = mkOption {
        type = types.str;
        default = config.services.mpd.network.listenAddress;
        defaultText = "config.services.mpd.network.listenAddress";
        example = "192.168.1.1";
        description = "The address where MPD is listening for connections.";
      };

      port = mkOption {
        type = types.port;
        default = config.services.mpd.network.port;
        defaultText = "config.services.mpd.network.port";
        description = ''
          The port number where MPD is listening for connections.
        '';
      };

      musicDirectory = mkOption {
        type = types.nullOr types.path;
        default = config.services.mpd.musicDirectory;
        defaultText = "config.services.mpd.musicDirectory";
        description = ''
          If set, mpDris2 will use this directory to access music artwork.
        '';
      };

      service = mkOption {
        type = types.nullOr types.str;
        default = "mpd.service";
        description = ''
          The systemd service name for MPD.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = hasAttr (removeSuffix ".service" cfg.mpd.service) config.systemd.user.services;
      message = "The mpdris2 module requires 'services.mpd.enable = true' or setting 'services.mpdris2.mpd.service' set to a systemd service name.";
    }];

    xdg.configFile."mpDris2/mpDris2.conf".text = toIni mpdris2Conf;

    systemd.user.services.mpdris2 = {
      Install = { WantedBy = [ "default.target" ]; };

      Unit = {
        Description = "MPRIS 2 support for MPD";
        After = [ cfg.mpd.service ];
      };

      Service = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "5s";
        ExecStart = "${cfg.package}/bin/mpDris2";
        BusName = "org.mpris.MediaPlayer2.mpd";
      };
    };
  };
}
