{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.workstation {
  environment.systemPackages = with pkgs; [
    firefox ungoogled-chromium
    pavucontrol qalculate-gtk
    element-desktop jitsi-meet-electron teams-for-linux webcord
    ffmpeg-full (lib.hiPrio (wrapMpv (mpv-unwrapped.override { ffmpeg = ffmpeg-full; }) {}))
    # TODO: re-add ripgrep-all when the 1.0.0 release is made and makes it into nixpkgs
    fq #ripgrep-all
    mkusb mkwin
    aria2 openssl wireshark dogdns picocom
    gnumake llvmPackages_16.clang llvmPackages_16.lldb
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
