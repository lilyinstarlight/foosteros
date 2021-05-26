{ config, lib, pkgs, ... }:

{
  imports = [
    <home-manager/nixos>
  ];

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  environment.systemPackages = with pkgs; [
    any-nix-shell
    pridecat
    ripgrep-all
  ];

  users.users.lily = {
    description = "Lily Foster";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.petty;
  };

  home-manager.users.lily = { pkgs, ... }: {
    services.udiskie = {
      enable = true;
      tray = "never";
    };

    programs.fish = {
      enable = true;
      plugins = pkgs.callPackage ../misc/fish-plugins/default.nix {};
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
      promptInit = ''
        fish_vi_key_bindings
        any-nix-shell fish --info-right | source
      '';
    };

    programs.git = {
      enable = true;
      userName = "Lily Foster";
      userEmail = "lily@lily.flowers";
      signing.key = "2E23AF668B14BA1F";
      extraConfig = {
        core.pager = "${pkgs.pridecat}/bin/pridecat --trans -f | ${pkgs.gitAndTools.delta}/bin/delta --dark";
        init.defaultBranch = "main";
        pull.ff = "only";
      };
      aliases = {
        kill = "!sh -c 'git reset HEAD --hard && git clean -xdf'";
        subupd = "submodule update --init";
        subpull = "submodule foreach git pull";
        uppull = "pull upstream HEAD";
      };
    };

    home.file.".config/petty/pettyrc".text = ''
      shell=fish
      session1=sway
    '';
  };
}
