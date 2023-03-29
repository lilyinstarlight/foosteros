{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.hyfetch {
  environment.systemPackages = with pkgs; [
    hyfetch

    (writeShellApplication {
      name = "neofetch";
      runtimeInputs = with pkgs; [ hyfetch ];
      text = ''
        distro="FoosterOS/2 Warp (NixOS ${config.system.nixos.release}) $(uname -m)" exec neowofetch --colors 5 4 4 5 4 7 --ascii_distro nixos --ascii_colors 5 4 --separator ' ->' "$@"
      '';
    })
  ];

  home-manager.sharedModules = [
    {
      programs.hyfetch = {
        enable = true;
        settings = {
          preset = "transfeminine";
          mode = "rgb";
          light_dark = "dark";
          lightness = 0.5;
          color_align = {
            mode = "horizontal";
            custom_colors = [ ];
            fore_back = null;
          };
        };
      };
    }
  ];
}
