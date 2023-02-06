{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    firefox ungoogled-chromium
    pavucontrol qalculate-gtk
    element-desktop jitsi-meet-electron teams-for-linux webcord
    ffmpeg-full
    fq ripgrep-all
    mkusb mkwin
    aria2 openssl wireshark dogdns picocom
    gnumake llvmPackages_latest.clang llvmPackages_latest.lldb
  ] ++ (lib.optionals config.nixpkgs.config.allowUnfree [
    pridecat
    slack
  ]);
}
