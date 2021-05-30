{ config, lib, pkgs, ... }:

{
  imports = [
    <home-manager/nixos>
  ];

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.sharedModules = [
    ../modules/home-manager/services/audio/mopidy.nix
    ../modules/home-manager/services/audio/mpdris2.nix
  ];

  environment.systemPackages = with pkgs; [
    any-nix-shell
    udiskie
    pridecat
    ripgrep-all
  ];

  users.users.lily = {
    description = "Lily Foster";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = lib.mkDefault pkgs.fish;
  };

  home-manager.users.lily = { pkgs, ... }: {
    programs.fish = {
      enable = true;
      plugins = pkgs.callPackage ../misc/fish-plugins/default.nix {};
      promptInit = ''
        fish_vi_key_bindings
      '';
    };

    programs.git = {
      enable = true;
      userName = "Lily Foster";
      userEmail = "lily@lily.flowers";
      signing.key = "2E23AF668B14BA1F";
      extraConfig = {
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
  };
}
