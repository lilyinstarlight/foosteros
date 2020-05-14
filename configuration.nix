{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.nixos.label = "FoosterOS";

  networking.hostName = "bina";
  # networking.wireless.enable = true; 
  networking.useNetworkd = true;

  networking.useDHCP = false;
  networking.interfaces.ens33.useDHCP = true;

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  time.timeZone = "America/New_York";

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    file htop tmux neovim git
    qutebrowser firefox google-chrome
  ];

  environment.shellAliases = {
    vi = "nvim";
  };

  environment.homeBinInPath = true;

  environment.etc = {
    issue.source = lib.mkForce (pkgs.writeText "issue" ''
  
      Welcome to [1;35mFoosterOS/2[0m [1;34mWarp[0m - \l
  
    '');
  };

  programs.fish.enable = true;
  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      swaylock swayidle xwayland alacritty
    ];
  };

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.openssh.enable = true;
  # services.printing.enable = true;

  services.xserver = {
    layout = "us";
    # xkbModel = "apple_laptop";
    # xkbVariant = "mac";
    xkbOptions = "caps:escape";
    libinput.enable = true;
  };

  services.nullmailer = {
    enable = true;
    config = {
      me = "bina.fooster.network";
      defaultdomain = "fooster.network";
      allmailfrom = "lily@fooster.network";
      adminaddr = "logs@fooster.network";
    };
    # remotesFile = "";
  };

  users.users.lily = {
    description = "Lily Foster";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };

  virtualisation.vmware.guest.enable = true;

  system.stateVersion = "20.03";
}
