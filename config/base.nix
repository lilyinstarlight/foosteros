{ config, lib, pkgs, self, inputs, outputs, ... }:

{
  imports = [
    ../modules/nixos/boot/systemd-boot.nix
    ../modules/nixos/programs/kanshi.nix
    ../modules/nixos/programs/mako.nix
    ../modules/nixos/programs/sway.nix
    ../modules/nixos/services/misc/swaynag-battery.nix

    ./fish.nix
    ./neovim.nix
    ./tmux.nix
  ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    sharedModules = [
      ../modules/home-manager/services/audio/mopidy.nix
      ../modules/home-manager/services/audio/mpdris2.nix
      {
        xdg.userDirs = {
          enable = true;
          desktop = "$HOME";
          documents = "$HOME/docs";
          download = "$HOME/tmp";
          music = "$HOME/music";
          pictures = "$HOME/pics";
          publicShare = "$HOME/public";
          templates = "$HOME/.templates";
          videos = "$HOME/vids";
        };
      }
    ];
  };

  boot.loader = {
    efi.canTouchEfiVariables = true;

    systemd-boot = {
      enable = true;
      bootName = "FoosterOS/2 Warp";
    };
  };

  networking = {
    useDHCP = false;
    useNetworkd = true;
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  time.timeZone = "America/New_York";

  nix = {
    package = pkgs.nixUnstable;

    binaryCachePublicKeys = [ "foosteros.cachix.org-1:rrDalTfOT1YohJXiMv8upgN+mFLKZp7eWW1+OGbPRww=" ];
    binaryCaches = [ "https://foosteros.cachix.org/" ];

    extraOptions = ''
      experimental-features = nix-command ca-references flakes
    '';

    registry = (lib.mapAttrs (name: value: { flake = value; }) (lib.filterAttrs (name: value: value ? outputs) inputs)) // { foosteros = { flake = self; }; };
    nixPath = (lib.mapAttrsToList (name: value: name + "=" + value) inputs) ++ [ ("foosteros=" + ../.) ("nixpkgs-overlays=" + ../. + "/overlays.nix") ];
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = lib.attrValues outputs.overlays;
  };

  environment.variables = {
    EDITOR = "vi";
    VISUAL = "vi";
  };

  environment.homeBinInPath = true;

  environment.etc = {
    "nix/nixpkgs-config.nix".text = lib.mkDefault ''
      {
        allowUnfree = ${lib.boolToString config.nixpkgs.config.allowUnfree};
      }
    '';

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
      HOME_URL="https://github.com/lilyinstarlight/foosteros"
      DOCUMENTATION_URL="https://nixos.org/learn.html"
      BUG_REPORT_URL="https://github.com/lilyinstarlight/foosteros/issues"
    '';

    "xdg/user-dirs.defaults".text = ''
      XDG_DESKTOP_DIR="$HOME"
      XDG_DOCUMENTS_DIR="$HOME/docs"
      XDG_DOWNLOAD_DIR="$HOME/tmp"
      XDG_MUSIC_DIR="$HOME/music"
      XDG_PICTURES_DIR="$HOME/pics"
      XDG_PUBLICSHARE_DIR="$HOME/public"
      XDG_TEMPLATES_DIR="$HOME/.templates"
      XDG_VIDEOS_DIR="$HOME/vids"
    '';

    gitconfig.text = lib.mkDefault ''
      [core]
      	pager = "${pkgs.gitAndTools.delta}/bin/delta --dark"

      [interactive]
      	diffFilter = "${pkgs.gitAndTools.delta}/bin/delta --dark --color-only"
    '';
  };

  environment.systemPackages = with pkgs; [
    bc file htop python3 tree unzip xxd
    cachix fpaste ftmp furi
    git gitAndTools.delta ripgrep
    shellcheck progress
  ];

  environment.shellAliases = {
    ls = "ls --color=tty -h";
    df = "df -h";
    du = "du -h";
    free = "free -h";
    bc = "bc -l";
    curl = "curl -L";
    cget = "command curl -fLJO --progress-bar --retry 10 -C -";
  };

  programs.command-not-found.enable = false;

  sound.enable = true;

  services.openssh.enable = true;

  services.xserver = {
    layout = "us";
    xkbOptions = "caps:escape";

    libinput.enable = true;
  };
}
