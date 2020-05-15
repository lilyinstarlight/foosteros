{ config, lib, pkgs, ... }:

{
  imports = [
    # ./nvim.nix
    # ./sway.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.nixos.label = "FoosterOS";

  networking.domain = "fooster.network";

  networking.useDHCP = false;
  networking.useNetworkd = true;

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  time.timeZone = "America/New_York";

  environment.variables = {
    EDITOR = "vi";
    VISUAL = "vi";
  };

  environment.homeBinInPath = true;

  environment.etc = {
    issue.source = lib.mkForce (pkgs.writeText "issue" ''

      Welcome to [1;35mFoosterOS/2[0m [1;34mWarp[0m - \l

    '');
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (self: super: (import ../pkgs/default.nix { pkgs = super; }))
    ];
  };

  environment.systemPackages = with pkgs; [
    file htop tmux fooster.neovim
    git gitAndTools.delta silver-searcher
  ];

  programs.fish.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  services.openssh.enable = true;

  services.xserver = {
    layout = "us";
    xkbOptions = "caps:escape";

    libinput.enable = true;
  };

  users.users.lily = {
    description = "Lily Foster";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };

  system.stateVersion = "20.03";
}
