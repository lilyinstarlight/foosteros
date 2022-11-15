{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.boot.loader.systemd-boot;
in

{
  options.boot.loader.systemd-boot = {
    bootName = mkOption {
      default = "NixOS";

      type = types.str;

      description = mdDoc ''
        Name to put in boot entry titles.
      '';
    };
  };

  config = mkIf cfg.enable {
    boot.loader.systemd-boot.extraInstallCommands = ''
      sed -i -e 's/^title NixOS$/title '${escapeShellArg cfg.bootName}'/' /boot/loader/entries/"$(grep '^default' /boot/loader/loader.conf | awk '{print $2}')"
    '';
  };
}
