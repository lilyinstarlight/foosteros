{ config, lib, pkgs, ... }:

{
  imports = [
    ../modules/systemd-boot/systemd-boot.nix
    # ./nvim.nix
    # ./sway.nix
  ];

  boot.loader = {
    efi.canTouchEfiVariables = true;

    systemd-boot = {
      enable = true;
      bootName = "FoosterOS/2 Warp";
    };
  };

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

    os-release.text = lib.mkForce ''
        NAME=FoosterOS
        ID=nixos
        VERSION="Warp"
        VERSION_CODENAME=${lib.toLower config.system.nixos.codeName}
        VERSION_ID="${config.system.nixos.version}"
        PRETTY_NAME="FoosterOS/2 Warp"
        LOGO="nix-snowflake"
        HOME_URL="https://fooster.io/"
        DOCUMENTATION_URL="https://nixos.org/learn.html"
        SUPPORT_URL="https://nixos.org/community.html"
        BUG_REPORT_URL="https://github.com/NixOS/nixpkgs/issues"
      '';
    };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (self: super: (import ../pkgs/default.nix { pkgs = super; }))
    ];
  };

  environment.systemPackages = with pkgs; [
    file htop tmux fooster.neovim python3
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
