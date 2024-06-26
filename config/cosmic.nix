{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.cosmic {
  foosteros.profiles = {
    fonts = lib.mkDefault true;
    pipewire = lib.mkDefault true;
  };

  boot.loader.timeout = 0;

  boot.plymouth = {
    enable = true;
    theme = "nixos-bgrt";
    themePackages = [ pkgs.nixos-bgrt-plymouth ];
  };

  environment.variables = {
    NIXOS_OZONE_WL = "1";
  };

  nix.settings = {
    substituters = [ "https://cosmic.cachix.org" ];
    trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
  };

  services.flatpak.enable = true;

  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;
}
