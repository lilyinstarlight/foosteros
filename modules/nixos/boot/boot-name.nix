{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.system.nixos;
in

{
  options.system.nixos = {
    bootName = mkOption {
      default = "NixOS";

      type = types.str;

      description = mdDoc ''
        Name to put in boot entry titles.
      '';
    };
  };

  config = mkMerge [
    (mkIf config.boot.bootspec.enable {
      system.extraSystemBuilderCmds = ''
        substituteInPlace $out/boot.json --replace \
            '"label": "NixOS '${escapeShellArg cfg.codeName}' ' \
            '"label": "'${escapeShellArg cfg.bootName}' ('${escapeShellArg cfg.codeName}') '
      '';
    })
    (mkIf config.boot.loader.systemd-boot.enable {
      boot.loader.systemd-boot.extraInstallCommands = ''
        find /boot/loader/entries -name '*.conf' -exec sed -i -e 's#^title NixOS$#title '${escape ["#"] (escapeShellArg cfg.bootName)}'#' {} +
      '';
    })
  ];
}
