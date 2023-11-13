{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.hardware.tkey;
in

{
  options.hardware.tkey = {
    enable = mkEnableOption ''
      Enable udev rules for interfacing with the TKey-1 USB security token
    '';

    group = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc ''
        Grant access to TKey-1 devices to users in this group.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.udev.packages = [
      (pkgs.writeTextFile {
        name = "51-tkey.rules";
        destination = "/lib/udev/rules.d/51-tkey.rules";
        text = ''
          ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="1207", ATTRS{idProduct}=="8887"${lib.optionalString (cfg.group != null) '', MODE="0660", GROUP="${cfg.group}"''}, TAG+="uaccess"
        '';
      })
    ];
  };
}
