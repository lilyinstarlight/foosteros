{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.workstation {
  environment.systemPackages = with pkgs; [
    firefox ungoogled-chromium
    pavucontrol qalculate-gtk
    (element-desktop.override { element-web = element-web.override { conf.show_labs_settings = true; }; }) mattermost-desktop /*jitsi-meet-electron*/ teams-for-linux webcord
    ffmpeg-full (lib.hiPrio (mpv-unwrapped.wrapper { mpv = mpv-unwrapped.override { ffmpeg = ffmpeg-full; }; }))
    fq ripgrep-all
    mkusb mkwin
    aria2 openssl wireshark doggo picocom
    gnumake llvmPackages.clang llvmPackages.lldb
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
}
