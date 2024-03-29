{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.udiskie {
  environment.systemPackages = with pkgs; [
    udiskie
  ];

  services.udisks2.enable = true;

  home-manager.sharedModules = [
    ({ config, lib, ... }: {
      services.udiskie = {
        enable = true;
        automount = false;
        tray = "never";
      };

      home.activation = {
        linkHomeMnt = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          $DRY_RUN_CMD ln -sTf $VERBOSE_ARG /run/media/"$USER" "$HOME"/mnt
        '';
      };
    })
  ];
}
