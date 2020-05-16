{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../config/default.nix
    ../../config/sway.nix
  ];

  networking.hostName = "bina.fooster.network";

  # networking.wireless.enable = true;
  networking.interfaces.ens33.useDHCP = true;

  environment.systemPackages = with pkgs; [
    pass-wayland
  ];

  environment.etc."sway/config.d/bina".text = ''
    ### ouputs
    #output eDP-1 resolution 2880x1800 position 0 0 scale 2
    output Virtual-1 resolution 2880x1800 position 0 0 scale 2

    ### inputs
    #input "1739:1751:Apple_SPI_Touchpad" {
    #    click_method clickfinger
    #    dwt enabled
    #    middle_emulation enabled
    #    natural_scroll enabled
    #    scroll_method two_finger
    #    tap enabled
    #    pointer_accel 0.8
    #}
    #
    #input "76:617:FoosterMOUSE_Mouse" {
    #    natural_scroll enabled
    #    scroll_button 273
    #    scroll_method on_button_down
    #}
  '';

  # services.printing.enable = true;

  services.xserver = {
    # xkbModel = "apple_laptop";
    # xkbVariant = "mac";
  };

  services.nullmailer = {
    enable = true;
    config = {
      me = config.networking.hostName;
      defaultdomain = "fooster.network";
      allmailfrom = "lily@fooster.network";
      adminaddr = "logs@fooster.network";
    };
    # remotesFile = "";
  };

  # services.tlp.enable = true;

  virtualisation.vmware.guest.enable = true;

  system.stateVersion = "20.09";
}
