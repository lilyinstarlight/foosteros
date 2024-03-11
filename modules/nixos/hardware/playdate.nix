{ config, pkgs, lib, ... }:

let
  cfg = config.hardware.playdate;
in

{
  options.hardware.playdate = {
    enable = lib.mkEnableOption ''
      Enable udev rules for interfacing with the Playdate handheld console
    '';

    group = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = ''
        Grant access to Playdate devices to users in this group.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
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
