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
    } // optionalAttrs (cfg.mpd.password != null) {
      password = cfg.mpd.password;
    };

    Bling = {
      notify = cfg.notifications;
      mmkeys = cfg.multimediaKeys;
      cdprev = cfg.cdPrevious;
    };
  };

in {
  options.services.mpdris2 = {
    cdPrevious = mkEnableOption "CD-like previous command";
  };

  config = mkIf cfg.enable {
    xdg.configFile."mpDris2/mpDris2.conf".text = mkOverride 75 (toIni mpdris2Conf);  # 50 is force prio and 100 is default prio

    systemd.user.services.mpdris2 = {
      Service.Type = mkOverride 75 "dbus";  # 50 is force prio and 100 is default prio
    };
  };
}
