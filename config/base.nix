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
    BUG_REPORT_URL = "https://github.com/lilyinstarlight/foosteros/issues";
  } // lib.optionalAttrs (config.system.nixos.variant_id != null) {
    VARIANT_ID = config.system.nixos.variant_id;
  };

  initrdReleaseContents = (removeAttrs osReleaseContents [ "BUILD_ID" ]) // {
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

lib.mkIf config.foosteros.profiles.base {
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    sharedModules = [
      {
        home.stateVersion = config.system.stateVersion;
      }
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
    ];
  };

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.arp_filter" = 1;
  };

  boot.consoleLogLevel = 3;
  boot.kernelParams = [ "quiet" ];

  boot.bootspec.enable = true;

  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.systemd = {
    enable = true;

    contents = {
      "/etc/os-release".source = lib.mkOverride 75 initrdRelease;  # 50 is force prio and 100 is default prio
      "/etc/initrd-release".source = lib.mkOverride 75 initrdRelease;
    };
  };

  networking.useDHCP = false;

  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  console = {
    font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-v${toString config.system.devices.monitorFontSize}n.psf.gz";
    earlySetup = true;
    useXkbConfig = true;
  };

  time.timeZone = lib.mkDefault "America/New_York";

  nix = {
    settings = {
      auto-allocate-uids = true;
      substituters = [ "https://foosteros.cachix.org/" ];
      trusted-public-keys = [ "foosteros.cachix.org-1:rrDalTfOT1YohJXiMv8upgN+mFLKZp7eWW1+OGbPRww=" ];
      experimental-features = [ "nix-command" "flakes" "repl-flake" "auto-allocate-uids" ];
      flake-registry = "${inputs.flake-registry}/flake-registry.json";
    };

    registry = (lib.mapAttrs (name: value: { flake = value; }) (lib.filterAttrs (name: value: value ? outputs) inputs)) // { foosteros = { flake = self; }; };
    nixPath = map (name: "${name}=/etc/nix/path/${name}") (lib.attrNames inputs ++ [ "foosteros" "nixpkgs-overlays" ]);
  };

  nixpkgs = {
    config = {
      allowAliases = false;
      allowUnfree = true;
    };
    overlays = lib.attrValues (removeAttrs self.overlays [ "default" ]);
  };

  system = {
    configurationRevision = self.rev or null;
    nixos = {
      distroName = "FoosterOS/2 Warp";
      label = lib.concatStringsSep "-" ((lib.sort (x: y: x < y) config.system.nixos.tags) ++ [ config.system.nixos.version ] ++ [ "foosteros" (self.shortRev or "dirty") ]);
    };
  };

  environment.variables = {
    EDITOR = "vi";
    VISUAL = "vi";
  };

  environment.homeBinInPath = true;

  environment.etc = {
    "nix/nixpkgs-config.nix".text = lib.mkDefault ''
      {
        allowUnfree = ${lib.boolToString (config.nixpkgs.config.allowUnfree or false)};
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
      	pager = "${pkgs.delta}/bin/delta --dark"

      [interactive]
      	diffFilter = "${pkgs.delta}/bin/delta --dark --color-only"
    '';
  } // lib.mapAttrs' (name: value: lib.nameValuePair "nix/path/${name}" { source = builtins.toString value; }) (inputs // {
    foosteros = ../.;
    nixpkgs-overlays = ../. + "/overlays.nix";
  });

  environment.defaultPackages = lib.mkDefault [];

  environment.systemPackages = with pkgs; [
    man-pages man-pages-posix
    dbus file python3 rsync strace tree unzip xxd
    cachix fpaste ftmp furi
    git delta fd ripgrep
    shellcheck progress libqalculate
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
  programs.comma.enable = true;

  programs.htop = {
    enable = true;
    settings = {
      tree_view = true;
    };
  };

  sound.enable = true;

  services.dbus.implementation = "broker";

  services.resolved.enable = lib.mkDefault true;

  services.journald.extraConfig = lib.mkDefault ''
    SystemMaxUse=256M
  '';

  services.openssh.enable = true;

  services.xserver = {
    layout = "us";
    xkbOptions = "caps:escape";

    libinput.enable = true;
  };

  systemd.oomd = {
    enableSystemSlice = lib.mkDefault true;
    enableRootSlice = lib.mkDefault true;
    enableUserServices = lib.mkDefault true;
  };
}
