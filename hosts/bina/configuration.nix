{ config, lib, pkgs, ... }:

{
  imports = [
    ./disks.nix
    ./hardware.nix
  ];

  foosteros.profiles = {
    lily = true;

    restic = true;

    adb = true;
    alien = true;
    azure = true;
    bluetooth = true;
    builders = true;
    cad = true;
    fcitx5 = true;
    fprint = true;
    fwupd = true;
    gc = true;
    gnupg = true;
    hibernate = true;
    homebins = true;
    hyfetch = true;
    ledger = true;
    libvirt = true;
    lsp = true;
    miracast = true;
    music = true;
    networkmanager = true;
    nullmailer = true;
    pass = true;
    pki = true;
    playdate = true;
    podman = true;
    preservation = true;
    printing = true;
    production = true;
    secureboot = true;
    sops = true;
    steam = true;
    sway = true;
    sysrq = true;
    tex = true;
    tkey = true;
    udiskie = true;
    workstation = true;
  };

  sops = {
    defaultSopsFile = ./secrets.yaml;
    secrets = {
      root-password = {
        neededForUsers = true;
      };
      lily-password = {
        neededForUsers = true;
      };
      restic-backup-password = {};
      restic-backup-environment = {};
      dnsimple-ddns = {};
      nullmailer-remotes = {
        mode = "0440";
        group = config.services.nullmailer.group;
        restartUnits = [ "nullmailer.service" ];
      };
    } // (let
      mkNmSecret = name: lib.nameValuePair "networks/${name}" {
        restartUnits = [ "NetworkManager.service" ];
      };
    in lib.listToAttrs (map mkNmSecret [
      "home"
      "admin"
      "mobile"
      "wired"
      "wired-admin"
      "josie"
      "mallory"
      "cynthia"
      "carolina"
      "allison"
      "emma"
    ]));
  };

  preservation.preserveAt = {
    ${config.system.devices.preservedState} = {
      users.lily = {
        directories = [
          ".local/share/PrismLauncher"
          ".Playdate Simulator"
        ];
      };
    };
  };

  networking = {
    hostName = "bina";
    domain = "fooster.network";
  };

  services.restic.backups.bina = {
    passwordFile = config.sops.secrets.restic-backup-password.path;
    environmentFile = config.sops.secrets.restic-backup-environment.path;
  };

  virtualisation.spiceUSBRedirection.enable = true;

  nix = {
    settings = {
      substituters = [ "https://cosmic.cachix.org" ];
      trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
      keep-outputs = true;
      cores = 8;
      max-jobs = 2;
    };
  };

  environment.etc = {
    "sway/config.d/bina".text = ''
      ### ouputs
      output eDP-1 resolution 2256x1504 position 0,0 scale 1.5

      ### inputs
      input type:keyboard {
          xkb_options caps:escape
      }

      input "1:1:AT_Translated_Set_2_keyboard" {
          xkb_layout us
      }

      input "2362:628:PIXA3854:00_093A:0274_Touchpad" {
          click_method clickfinger
          dwt enabled
          middle_emulation enabled
          natural_scroll enabled
          scroll_method two_finger
          tap enabled
      }

      input "5426:132:Razer_Razer_DeathAdder_V2" {
        pointer_accel -0.6
      }

      ### rules
      for_window [title="Qsynth"] floating enable
      for_window [title=".* — QjackCtl"] floating enable
      for_window [title="Virtual MIDI Piano Keyboard"] floating enable
    '';
  } // (lib.mapAttrs'
    (name: value: lib.nameValuePair "NetworkManager/system-connections/${lib.removePrefix "networks/" name}" { source = value.path; })
    (lib.filterAttrs (name: value: lib.hasPrefix "networks/" name) config.sops.secrets)
  );

  programs.kanshi.profiles = {
    internal = {
      outputs = {
        "eDP-1" = "enable mode 2256x1504 position 0,0 scale 1.5";
      };
    };

    desk = {
      outputs = {
        "eDP-1" = "enable mode 2256x1504 position 1920,0 scale 1.5";
        "VIZIO, Inc E390i-A1 0x01010101" = "enable mode 1920x1080 position 0,0 scale 1";
      };
      commands = [
        "${lib.getExe' pkgs.sway "swaymsg"} workspace number 3, move workspace to eDP-1"
        "${lib.getExe' pkgs.sway "swaymsg"} workspace number 1, move workspace to '\"VIZIO, Inc E390i-A1 0x01010101\"'"
      ];
    };

    deskonly = {
      outputs = {
        "eDP-1" = "disable";
        "VIZIO, Inc E390i-A1 0x01010101" = "enable mode 1920x1080 position 0,0 scale 1";
      };
    };
  };

  environment.systemPackages = with pkgs; [ handbrake mkvtoolnix prismlauncher subtitleedit ];

  services.fwupd.extraRemotes = [ "lvfs-testing" ];

  services.tlp.enable = true;

  services.nullmailer.remotesFile = config.sops.secrets.nullmailer-remotes.path;
  systemd.services.nullmailer.serviceConfig = {
    SupplementaryGroups = [ config.users.groups.keys.name ];
  };

  services.dnsimple-ddns = {
    enable = true;
    configFile = config.sops.secrets.dnsimple-ddns.path;
  };

  services.logmail = {
    enable = true;
    settings = {
      mailfrom = "logs@fooster.network";
      mailto = "logs@fooster.network";
      subject = "Logs for %h at %F %R";
    };
    filter = ''
      Failed to adjust quota for subvolume "/srv": Bad file descriptor
      Failed to adjust quota for subvolume "/var/lib/portables": Bad file descriptor
      Failed to adjust quota for subvolume "/var/lib/machines": Bad file descriptor
      bluetoothd\[[0-9]*\]: src/plugin\.c:plugin_init() Failed to init vcp plugin
      bluetoothd\[[0-9]*\]: src/plugin\.c:plugin_init() Failed to init mcp plugin
      bluetoothd\[[0-9]*\]: src/plugin\.c:plugin_init() Failed to init bap plugin
      bluetoothd\[[0-9]*\]: profiles/sap/server\.c:sap_server_register() Sap driver initialization failed\.
      bluetoothd\[[0-9]*\]: sap-server: Operation not permitted (1)
      bluetoothd\[[0-9]*\]: src/profile\.c:record_cb() Unable to get Hands-Free Voice gateway SDP record: Host is down
      bluetoothd\[[0-9]*\]: src/device\.c:set_wake_allowed_complete() Set device flags return status: Invalid Parameters
      kernel: tpm tpm0: \[Firmware Bug\]: TPM interrupt not working, polling instead
      kernel: cros-usbpd-charger cros-usbpd-charger\.[0-9]\.auto: Unexpected number of charge port count
      kernel: cros-usbpd-charger cros-usbpd-charger\.[0-9]\.auto: probe with driver cros-usbpd-charger failed with error -71
      kernel: cros_ec_lpcs cros_ec_lpcs\.0: bad packet checksum [0-9a-f]\{2\}
      kernel: cros_ec_lpcs cros_ec_lpcs\.0: packet too long ([0-9]* bytes, expected [0-9]*)
      systemd-udevd\[[0-9]*\]: /nix/store/[0-9a-z]\{32\}-systemd-[^/]*/lib/udev/rules\.d/50-udev-default\.rules:[0-9]* Unknown group '[^']*', ignoring
      systemd-udevd\[[0-9]*\]: event_source: Failed to get device name: No such file or directory
      dbus-broker-launch\[[0-9]*\]: Ignoring duplicate name '[^']*' in service file '[^']*'
      cupsd\[[0-9]*\]: \[Client [0-9]*\] Returning IPP client-error-not-possible for CUPS-Add-Modify-Printer ([^)]*) from localhost.
    '';
  };

  users = {
    mutableUsers = false;
    users = {
      root.hashedPasswordFile = config.sops.secrets.root-password.path;
      lily = {
        hashedPasswordFile = config.sops.secrets.lily-password.path;
        extraGroups = with config.users.groups; map (grp: grp.name) [ networkmanager keys ];
      };
    };
  };

  system.stateVersion = "23.11";
}
