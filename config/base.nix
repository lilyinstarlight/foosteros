{ config, lib, pkgs, self, inputs, outputs, ... }:

let
  issue = pkgs.writeText "issue" ''

    Welcome to [35;1mFoosterOS/2[0m [34;1mWarp[0m - \l

  '';

  osReleaseContents = {
    NAME = "NixOS";
    ID = "nixos";
    VERSION = "${config.system.nixos.release} (${config.system.nixos.codeName})";
    VERSION_CODENAME = lib.toLower config.system.nixos.codeName;
    VERSION_ID = config.system.nixos.release;
    BUILD_ID = config.system.nixos.version;
    PRETTY_NAME = "FoosterOS/2 Warp";
    LOGO = "nix-snowflake";
    HOME_URL = "https://nixos.org/";
    DOCUMENTATION_URL = "https://nixos.org/learn.html";
    SUPPORT_URL = "https://nixos.org/community.html";
    BUG_REPORT_URL = "https://github.com/NixOS/nixpkgs/issues";
  };

  initrdReleaseContents = osReleaseContents // {
    PRETTY_NAME = "${osReleaseContents.PRETTY_NAME} (Initrd)";
  };

  lsbReleaseContents = {
    LSB_VERSION = "${config.system.nixos.release} (${config.system.nixos.codeName})";
    DISTRIB_ID = "nixos";
    DISTRIB_RELEASE = config.system.nixos.release;
    DISTRIB_CODENAME = lib.toLower config.system.nixos.codeName;
    DISTRIB_DESCRIPTION = "FoosterOS/2 Warp";
  };

  needsEscaping = s: null != builtins.match "[a-zA-Z0-9]+" s;
  escapeIfNeccessary = s: if needsEscaping s then s else ''"${lib.escape [ "\$" "\"" "\\" "\`" ] s}"'';
  attrsToText = attrs:
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (n: v: ''${n}=${escapeIfNeccessary (toString v)}'') attrs
    ) + "\n";

  initrdRelease = pkgs.writeText "initrd-release" (attrsToText initrdReleaseContents);
in

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.sops-nix.nixosModules.sops
    inputs.impermanence.nixosModules.impermanence
  ] ++ (import ../modules/nixos/module-list.nix) ++ [
    ./fish.nix
    ./neovim.nix
    ./tmux.nix
  ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    sharedModules = [
      inputs.impermanence.nixosModules.home-manager.impermanence
    ] ++ (import ../modules/home-manager/module-list.nix) ++ [
      ({ pkgs, ... }: {
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
      })
      ({ pkgs, ... }: {
        home.file.".cache/nix-index/files".source = "${pkgs.nix-index-database}/files";
      })
    ];
  };

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.arp_filter" = 1;
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
    settings = {
      substituters = [ "https://foosteros.cachix.org/" ];
      trusted-public-keys = [ "foosteros.cachix.org-1:rrDalTfOT1YohJXiMv8upgN+mFLKZp7eWW1+OGbPRww=" ];
      experimental-features = [ "nix-command" "flakes" ];
    };

    registry = (lib.mapAttrs (name: value: { flake = value; }) (lib.filterAttrs (name: value: value ? outputs) inputs)) // { foosteros = { flake = self; }; };
    nixPath = (lib.mapAttrsToList (name: value: name + "=" + value) inputs) ++ [ ("foosteros=" + ../.) ("nixpkgs-overlays=" + ../. + "/overlays.nix") ];
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = lib.attrValues (removeAttrs outputs.overlays [ "default" ]);
  };

  system.nixos.label = lib.concatStringsSep "-" ((lib.sort (x: y: x < y) config.system.nixos.tags) ++ [ config.system.nixos.version ] ++ [ "foosteros" (self.shortRev or "dirty") ]);

  boot.initrd.systemd.contents = {
    "/etc/os-release".source = lib.mkForce initrdRelease;
    "/etc/initrd-release".source = lib.mkForce initrdRelease;
  };

  environment.variables = {
    EDITOR = "vi";
    VISUAL = "vi";

    NIX_LD = "$(cat ${pkgs.stdenv.cc}/nix-support/dynamic-linker)";
  };

  environment.homeBinInPath = true;

  environment.etc = {
    "nix/nixpkgs-config.nix".text = lib.mkDefault ''
      {
        allowUnfree = ${lib.boolToString config.nixpkgs.config.allowUnfree};
      }
    '';

    issue.source = lib.mkForce issue;

    os-release.text = lib.mkForce (attrsToText osReleaseContents);
    lsb-release.text = lib.mkForce (attrsToText lsbReleaseContents);

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
    man-pages man-pages-posix
    bc file python3 tree unzip xxd
    cachix fpaste ftmp furi
    git gitAndTools.delta ripgrep
    shellcheck progress
    nix-index comma
  ];

  environment.shellAliases = {
    ls = "ls --color=tty -h";
    df = "df -h";
    du = "du -h";
    free = "free -h";
    bc = "bc -l";
    curl = "curl -L";
    cget = "command curl -fLJO --progress-bar";
  };

  programs.command-not-found.enable = false;

  programs.htop = {
    enable = true;
    settings = {
      tree_view = true;
    };
  };

  sound.enable = true;

  services.journald.extraConfig = lib.mkDefault ''
    SystemMaxUse=256M
  '';

  services.openssh.enable = true;

  services.xserver = {
    layout = "us";
    xkbOptions = "caps:escape";

    libinput.enable = true;
  };
}
