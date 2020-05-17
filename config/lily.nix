{ config, lib, pkgs, ... }:

{
  imports = [
    <home-manager/nixos>
  ];

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  users.users.lily = {
    description = "Lily Foster";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };

  home-manager.users.lily = { pkgs, ... }: {
    programs.fish = {
      enable = true;
      functions = {
        fish_greeting = "";
      };
    };

    programs.git = {
      enable = true;
      userName = "Foster McLane";
      userEmail = "fkmclane@gmail.com";
      aliases = {
        kill = "!sh -c 'git reset HEAD --hard && git clean -xdf'";
        subupd = "submodule update --init";
        subpull = "submodule foreach git pull";
        uppull = "pull upstream master";
      };
      delta = {
        enable = true;
        options = [ "--dark" ];
      };
    };
  };
}
