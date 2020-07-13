{ config, lib, pkgs, ... }:

{
  imports = [
    ../modules/boot/systemd-boot/systemd-boot.nix
    ../modules/services/misc/swaynag-battery.nix
    ../modules/programs/sway.nix
  ];

  boot.loader = {
    efi.canTouchEfiVariables = true;

    systemd-boot = {
      enable = true;
      bootName = "FoosterOS/2 Warp";
    };
  };

  networking.useDHCP = false;
  networking.useNetworkd = true;

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  time.timeZone = "America/New_York";

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (self: super: (import ../pkgs/default.nix { pkgs = super; }))
    ];
  };

  environment.variables = {
    EDITOR = "vi";
    VISUAL = "vi";
  };

  environment.homeBinInPath = true;

  environment.etc = {
    issue.source = lib.mkForce (pkgs.writeText "issue" ''

      Welcome to [35;1mFoosterOS/2[0m [34;1mWarp[0m - \l

    '');

    os-release.text = lib.mkForce ''
      NAME=NixOS
      ID=nixos
      VERSION="${config.system.nixos.version} (${config.system.nixos.codeName})"
      VERSION_CODENAME=${lib.toLower config.system.nixos.codeName}
      VERSION_ID="${config.system.nixos.version}"
      PRETTY_NAME="FoosterOS/2 Warp"
      LOGO="nix-snowflake"
      HOME_URL="https://github.com/fkmclane/foosteros"
      DOCUMENTATION_URL="https://nixos.org/learn.html"
      BUG_REPORT_URL="https://github.com/fkmclane/foosteros/issues"
    '';

    "xdg/user-dirs.defaults".text = ''
      XDG_DESKTOP_DIR=$HOME
      XDG_DOCUMENTS_DIR=$HOME/docs
      XDG_DOWNLOAD_DIR=$HOME/tmp
      XDG_MUSIC_DIR=$HOME/music
      XDG_PICTURES_DIR=$HOME/pics
      XDG_PUBLICSHARE_DIR=$HOME/public
      XDG_TEMPLATES_DIR=$HOME/.templates
      XDG_VIDEOS_DIR=$HOME/vids
    '';

    gitconfig.text = lib.mkDefault ''
      [core]
      	pager = "${pkgs.gitAndTools.delta}/bin/delta --dark"

      [interactive]
      	diffFilter = "${pkgs.gitAndTools.delta}/bin/delta --dark --color-only"
    '';
  };

  environment.systemPackages = with pkgs; [
    file htop tmux fooster.neovim python3
    cachix fooster.fpaste fooster.ftmp fooster.furi
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
}
