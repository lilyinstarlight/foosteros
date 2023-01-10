{ config, lib, pkgs, ... }:

{
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

      home.file."mnt".source = config.lib.file.mkOutOfStoreSymlink "/run/media/${config.home.username}";
    })
  ];
}
