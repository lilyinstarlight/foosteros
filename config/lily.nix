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
      signing = {
        key = "49340081E484C893!";
        signByDefault = true;
      };
      settings = {
        user = {
          name = "Lily Foster";
          email = "lily@lily.flowers";
        };
        checkout.defaultRemote = "origin";
        init.defaultBranch = "main";
        merge.conflictStyle = "diff3";
        pull.ff = "only";
        push.autoSetupRemote = true;
        alias = {
          kill = "!sh -c 'git reset HEAD --hard && git clean -xdf'";
          subupd = "submodule update --init";
          subpull = "submodule foreach git pull";
          uppull = "pull upstream HEAD";
        };
      };
    };

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "cl.forkos.org".user = "lilyinstarlight";
        "gerrit.lix.systems".user = "lilyinstarlight";
      };
    };
  };

  preservation.preserveAt = lib.mkIf config.preservation.enable {
    ${config.system.devices.preservedState} = {
      users.lily = {
        directories = [
          "docs"
          "emu"
          "music"
          "pics"
          "public"
          "src"
          "vids"
          ".config/dconf"
          { directory = ".ssh"; mode = "0700"; }
        ];
      };
    };

    ${config.system.devices.persistedState} = {
      users.lily = {
        directories = [
          "iso"
          "tmp"
        ];
      };
    };
  };

  systemd.tmpfiles.settings = lib.mkIf config.preservation.enable {
    preservation = {
      "/home/lily/.config".d = { user = "lily"; group = "users"; mode = "0755"; };
      "/home/lily/.local".d = { user = "lily"; group = "users"; mode = "0755"; };
      "/home/lily/.local/share".d = { user = "lily"; group = "users"; mode = "0755"; };
      "/home/lily/.local/state".d = { user = "lily"; group = "users"; mode = "0755"; };
    };
  };
}
