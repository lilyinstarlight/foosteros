{ config, pkgs, lib, ... }:

let
  cfg = config.hardware.uhid;
in

{
  meta.maintainers = with lib.maintainers; [ lilyinstarlight ];

  options.hardware.uhid = {
    enable = lib.mkEnableOption "udev rules for unprivileged UHID access";

    group = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Grant access to UHID for users in this group.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.udev.packages = [
      (pkgs.writeTextFile {
        name = "50-uhid.rules";
        destination = "/lib/udev/rules.d/50-uhid.rules";
        text = ''
          ACTION=="add", SUBSYSTEMS=="misc", KERNEL=="uhid"${lib.optionalString (cfg.group != null) '', MODE="0660", GROUP="${cfg.group}"''}, TAG+="uaccess"
        '';
      })
    ];
  };
}
