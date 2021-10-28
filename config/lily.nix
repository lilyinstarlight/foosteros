{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pridecat
  ];

  users.users.lily = {
    description = "Lily Foster";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = lib.mkOverride 500 (if (config.users.defaultUserShell == pkgs.petty) then pkgs.petty else pkgs.fish);  # 100 is default prio and 1000 is module default prio
  };

  home-manager.users.lily = { pkgs, ... }: {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
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
