{ config, lib, pkgs, ... }:

# TODO: remove when nix-community/lanzaboote#131 is merged
let
  cfg = config.boot.lanzaboote;
in

{
  environment.systemPackages = with pkgs; [
    sbctl
  ];

  boot.loader.systemd-boot.enable = false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  # TODO: remove when nix-community/lanzaboote#131 is merged
  systemd.services.fwupd = lib.mkIf config.services.fwupd.enable {
    # Tell fwupd to load its efi files from /run
    environment.FWUPD_EFIAPPDIR = "/run/fwupd-efi";
    serviceConfig.RuntimeDirectory = "fwupd-efi";
    # Place the fwupd efi files in /run and sign them
    preStart = ''
      cp ${config.services.fwupd.package.fwupd-efi}/libexec/fwupd/efi/fwupd*.efi /run/fwupd-efi/
      ${pkgs.sbsigntool}/bin/sbsign --key '${cfg.privateKeyFile}' --cert '${cfg.publicKeyFile}' /run/fwupd-efi/fwupd*.efi
    '';
  };
  services.fwupd.uefiCapsuleSettings = lib.mkIf config.services.fwupd.enable {
    DisableShimForSecureBoot = true;
  };
}
