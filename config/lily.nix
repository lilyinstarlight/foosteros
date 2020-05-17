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
      shellAliases = {
        ls = "ls --color=tty -h";
        df = "df -h";
        du = "du -h";
        free = "free -h";
        bc = "bc -l";
        curl = "curl -L";
        cget = "command curl -fLJO --progress-bar --retry 10 -C -";
      };
      promptInit = "fish_vi_key_bindings";
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

    xdg.userDirs = {
      enable = true;
      desktop = "$HOME";
      documents = "$HOME/docs";
      download = "$HOME/tmp";
      music = "$HOME/music";
      pictures = "$HOME/pics";
      publicShare = "$HOME/public";
      templates = "$HOME/.templates";
      videos = "$HOME/vids";
    };
  };
}
