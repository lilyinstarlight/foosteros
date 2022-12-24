{ config, lib, pkgs, utils, self, inputs, ... }:

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
    inputs.disko.nixosModules.disko
    self.nixosModules.foosteros
    ./fish.nix
    ./neovim.nix
    ./tmux.nix
  ];

  # provide default value for disko since their module does not
  disko.devices = {};

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    sharedModules = [
      inputs.impermanence.nixosModules.home-manager.impermanence
      self.homeManagerModules.foosteros
      ({ pkgs, ... }: {
        xdg.userDirs = {
          enable = true;
          desktop = "$HOME/";
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
        home.file.".cache/nix-index/files".source = inputs.nix-index-db.packages.${pkgs.stdenv.hostPlatform.system}.default;
      })
    ];
  };

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.arp_filter" = 1;
  };

  boot.consoleLogLevel = 3;
  boot.kernelParams = [ "quiet" ];

  boot.loader = {
    efi.canTouchEfiVariables = true;

    systemd-boot = {
      enable = lib.mkDefault true;
      consoleMode = lib.mkOverride 500 "keep";  # 100 is default prio and 1000 is module default prio
      bootName = "FoosterOS/2 Warp";
    };
  };

  boot.initrd.systemd = {
    enable = true;

    # TODO: See both of these for context
    #   * https://github.com/systemd/systemd/issues/24904#issuecomment-1328607139
    #   * https://github.com/systemd/systemd/issues/3551
    targets.initrd-root-device = let
      fs = config.fileSystems."/";
      unit = utils.escapeSystemdPath (
        if fs.device != null then fs.device
        else "/dev/disk/by-label/${fs.label}"
      );
    in {
      requires = [ "${unit}.device" ];
      after = [ "${unit}.device" ];
    };
    targets.initrd-root-fs = {
      after = [ "sysroot.mount" ];
    };
  };


  networking = {
    useDHCP = false;
    useNetworkd = true;
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v${if config.hardware.video.hidpi.enable then "32" else "16"}n.psf.gz";
    useXkbConfig = true;
  };

  time.timeZone = "America/New_York";

  nix = {
    settings = {
      substituters = [ "https://foosteros.cachix.org/" ];
      trusted-public-keys = [ "foosteros.cachix.org-1:rrDalTfOT1YohJXiMv8upgN+mFLKZp7eWW1+OGbPRww=" ];
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      flake-registry = "${inputs.flake-registry}/flake-registry.json";
    };

    registry = (lib.mapAttrs (name: value: { flake = value; }) (lib.filterAttrs (name: value: value ? outputs) inputs)) // { foosteros = { flake = self; }; };
    nixPath = (lib.mapAttrsToList (name: value: name + "=" + value) inputs) ++ [ ("foosteros=" + ../.) ("nixpkgs-overlays=" + ../. + "/overlays.nix") ];
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = lib.attrValues (removeAttrs self.overlays [ "default" ]);
  };

  system.nixos.label = lib.concatStringsSep "-" ((lib.sort (x: y: x < y) config.system.nixos.tags) ++ [ config.system.nixos.version ] ++ [ "foosteros" (self.shortRev or "dirty") ]);

  boot.initrd.systemd.contents = {
    "/etc/os-release".source = lib.mkOverride 75 initrdRelease;  # 50 is force prio and 100 is default prio
    "/etc/initrd-release".source = lib.mkOverride 75 initrdRelease;
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

    issue.source = issue;

    os-release.text = lib.mkOverride 75 (attrsToText osReleaseContents);  # 50 is force prio and 100 is default prio
    lsb-release.text = lib.mkOverride 75 (attrsToText lsbReleaseContents);

    "xdg/user-dirs.defaults".text = ''
      XDG_DESKTOP_DIR="$HOME/"
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
    file python3 tree unzip xxd
    cachix fpaste ftmp furi
    git gitAndTools.delta fd ripgrep
    shellcheck progress libqalculate
    nix-index comma
  ];

  environment.shellAliases = {
    ls = "ls --color=tty -h";
    df = "df -h";
    du = "du -h";
    free = "free -h";
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

  services.dbus.implementation = "broker";

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
