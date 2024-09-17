{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.lily {
  users.users.lily = {
    description = "Lily Foster";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = lib.mkOverride 500 pkgs.fish;  # 100 is default prio and 1000 is module default prio
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
      signing = {
        key = "49340081E484C893!";
        signByDefault = true;
      };
      extraConfig = {
        checkout.defaultRemote = "origin";
        init.defaultBranch = "main";
        merge.conflictStyle = "diff3";
        pull.ff = "only";
        push.autoSetupRemote = true;
      };
      aliases = {
        kill = "!sh -c 'git reset HEAD --hard && git clean -xdf'";
        subupd = "submodule update --init";
        subpull = "submodule foreach git pull";
        uppull = "pull upstream HEAD";
      };
    };

    programs.ssh = {
      enable = true;
      matchBlocks = {
        "cl.forkos.org".user = "lilyinstarlight";
        "gerrit.lix.systems".user = "lilyinstarlight";
      };
    };
  };
}
