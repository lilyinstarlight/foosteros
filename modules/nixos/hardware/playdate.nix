{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.hardware.playdate;
in

{
  options.hardware.playdate = {
    enable = mkEnableOption ''
      Enable udev rules for interfacing with the Playdate handheld console
    '';

    group = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = mdDoc ''
        Grant access to Playdate devices to users in this group.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.udev.packages = [
      (pkgs.writeTextFile {
        name = "51-playdate.rules";
        destination = "/lib/udev/rules.d/51-playdate.rules";
        text = ''
          ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="1331", ATTRS{idProduct}=="5740"${lib.optionalString (cfg.group != null) '', MODE="0660", GROUP="${cfg.group}"''}, TAG+="uaccess"
          ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="1331", ATTRS{idProduct}=="5741"${lib.optionalString (cfg.group != null) '', MODE="0660", GROUP="${cfg.group}"''}, TAG+="uaccess"
        '';
      })
    ];
  };
}
