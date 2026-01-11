{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.workstation {
  environment.systemPackages = with pkgs; [
    firefox ungoogled-chromium
    pavucontrol qalculate-gtk
    # TODO: remove when NixOS/nixpkgs#476071 is fixed
    #(element-desktop.override { element-web = element-web.override { conf.show_labs_settings = true; }; }) mattermost-desktop teams-for-linux webcord
    (element-desktop.override { element-web = element-web.override { conf.show_labs_settings = true; }; }) mattermost-desktop teams-for-linux (webcord.override { buildNpmPackage = buildNpmPackage.override { nodejs = nodejs_22; }; })
    ffmpeg-full (lib.hiPrio (mpv.override { mpv-unwrapped = mpv-unwrapped.override { ffmpeg = ffmpeg-full; }; }))
    fq ripgrep-all
    mkusb mkwin
    aria2 openssl wireshark doggo picocom
    gnumake llvmPackages.clang llvmPackages.lldb
    rustc rustfmt cargo clippy
  ] ++ (lib.optionals pkgs.config.allowUnfree [
    pridecat
    slack
  ]);

  home-manager.sharedModules = [
    {
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    }
  ];

  preservation.preserveAt = lib.mkIf (config.preservation.enable && (config.users.users.lily.enable or false)) {
    ${config.system.devices.preservedState} = {
      users.lily = {
        directories = [
          ".config/Element"
          ".config/Mattermost"
          ".config/teams-for-linux"
          ".config/WebCord"
          ".mozilla"
        ];
      };
    };

    ${config.system.devices.persistedState} = {
      users.lily = {
        directories = [
          { directory = ".cargo/registry"; configureParent = true; }
        ];
      };
    };
  };
}
