{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.workstation {
  environment.systemPackages = with pkgs; [
    firefox ungoogled-chromium
    pavucontrol qalculate-gtk
    # TODO: re-add once element-desktop overrides are fixed
    #(element-desktop.override { element-web = element-web.override { conf.show_labs_settings = true; }; }) signal-desktop webcord
    element-desktop signal-desktop webcord
    ffmpeg-full (lib.hiPrio (mpv.override { mpv-unwrapped = mpv-unwrapped.override { ffmpeg = ffmpeg-full; }; }))
    fq ripgrep-all
    magic-wormhole-rs
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
          ".config/Signal"
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
