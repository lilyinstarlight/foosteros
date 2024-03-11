{ config, pkgs, lib, ... }:

let
  cfg = config.hardware.tkey;
in

{
  meta.maintainers = with lib.maintainers; [ lilyinstarlight ];

  options.hardware.tkey = {
    enable = lib.mkEnableOption ''
      Enable udev rules for interfacing with the TKey-1 USB security token
    '';

    group = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Grant access to TKey-1 devices to users in this group.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.udev.packages = [
      (pkgs.writeTextFile {
        name = "51-tkey.rules";
        destination = "/lib/udev/rules.d/51-tkey.rules";
        text = ''
          ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="1207", ATTRS{idProduct}=="8887", ENV{ID_SECURITY_TOKEN}="1"${lib.optionalString (cfg.group != null) '', MODE="0660", GROUP="${cfg.group}"''}
        '';
      })
    ];
  };
}
