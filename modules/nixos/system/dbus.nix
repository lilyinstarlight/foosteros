# Derived from https://github.com/NixOS/nixpkgs under the following license:
#   Copyright (c) 2003-2022 Eelco Dolstra and the Nixpkgs/NixOS contributors
#
#   Permission is hereby granted, free of charge, to any person obtaining
#   a copy of this software and associated documentation files (the
#   "Software"), to deal in the Software without restriction, including
#   without limitation the rights to use, copy, modify, merge, publish,
#   distribute, sublicense, and/or sell copies of the Software, and to
#   permit persons to whom the Software is furnished to do so, subject to
#   the following conditions:
#
#   The above copyright notice and this permission notice shall be
#   included in all copies or substantial portions of the Software.
#
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
#   LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
#   OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
#   WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# D-Bus configuration and system bus daemon.

{ config, lib, options, pkgs, ... }:

with lib;

let

  cfg = config.services.dbus;

  brokerCfg = config.services.dbus-broker;

  homeDir = "/run/dbus";

  configDir = pkgs.makeDBusConf {
    inherit (cfg) apparmor;
    suidHelper = "${config.security.wrapperDir}/dbus-daemon-launch-helper";
    serviceDirectories = cfg.packages;
  };

in

{
  disabledModules = [ "services/system/dbus.nix" ];

  ###### interface

  options = {

    services.dbus-broker.enable = mkOption {
      type = types.bool;
      default = false;
      description = lib.mdDoc ''
        Whether to use dbus-broker as implementation of the message bus
        defined by the D-Bus specification. Its aim is to provide high
        performance and reliability, while keeping compatibility to the D-Bus
        reference implementation.
      '';
    };

    services.dbus = {

      enable = mkOption {
        type = types.bool;
        default = false;
        internal = true;
        description = lib.mdDoc ''
          Whether to start the D-Bus message bus daemon, which is
          required by many other system services and applications.
        '';
      };

      packages = mkOption {
        type = types.listOf types.path;
        default = [ ];
        description = lib.mdDoc ''
          Packages whose D-Bus configuration files should be included in
          the configuration of the D-Bus system-wide or session-wide
          message bus.  Specifically, files in the following directories
          will be included into their respective DBus configuration paths:
          {file}`«pkg»/etc/dbus-1/system.d`
          {file}`«pkg»/share/dbus-1/system.d`
          {file}`«pkg»/share/dbus-1/system-services`
          {file}`«pkg»/etc/dbus-1/session.d`
          {file}`«pkg»/share/dbus-1/session.d`
          {file}`«pkg»/share/dbus-1/services`
        '';
      };

      apparmor = mkOption {
        type = types.enum [ "enabled" "disabled" "required" ];
        description = lib.mdDoc ''
          AppArmor mode for dbus.
          `enabled` enables mediation when it's
          supported in the kernel, `disabled`
          always disables AppArmor even with kernel support, and
          `required` fails when AppArmor was not found
          in the kernel.
        '';
        default = "disabled";
      };

      socketActivated = mkOption {
        type = types.nullOr types.bool;
        default = null;
        visible = false;
        description = lib.mdDoc ''
          Removed option, do not use.
        '';
      };
    };
  };

  ###### implementation

  config = mkMerge [
    # You still need the dbus reference implementation installed to use dbus-broker
    (mkIf (cfg.enable || brokerCfg.enable) {
      warnings = optional (cfg.socketActivated != null) (
        let
          files = showFiles options.services.dbus.socketActivated.files;
        in
          "The option 'services.dbus.socketActivated' in ${files} no longer has"
          + " any effect and can be safely removed: the user D-Bus session is"
          + " now always socket activated."
      );

      environment.etc."dbus-1".source = configDir;

      users.users.messagebus = {
        uid = config.ids.uids.messagebus;
        description = "D-Bus system message bus daemon user";
        home = homeDir;
        group = "messagebus";
      };

      users.groups.messagebus.gid = config.ids.gids.messagebus;

      systemd.packages = [
        pkgs.dbus.daemon
      ];

      services.dbus.packages = [
        pkgs.dbus.out
        config.system.path
      ];

      systemd.user.sockets.dbus.wantedBy = [
        "sockets.target"
      ];

      environment.pathsToLink = [
        "/etc/dbus-1"
        "/share/dbus-1"
      ];
    })

    (mkIf cfg.enable {
      environment.systemPackages = [
        pkgs.dbus
        pkgs.dbus.daemon
      ];

      security.wrappers.dbus-daemon-launch-helper = {
        source = "${pkgs.dbus.daemon}/libexec/dbus-daemon-launch-helper";
        owner = "root";
        group = "messagebus";
        setuid = true;
        setgid = false;
        permissions = "u+rx,g+rx,o-rx";
      };

      systemd.services.dbus = {
        # Don't restart dbus-daemon. Bad things tend to happen if we do.
        reloadIfChanged = true;
        restartTriggers = [
          configDir
        ];
        environment = {
          LD_LIBRARY_PATH = config.system.nssModules.path;
        };
      };

      systemd.user.services.dbus = {
        # Don't restart dbus-daemon. Bad things tend to happen if we do.
        reloadIfChanged = true;
        restartTriggers = [
          configDir
        ];
      };
    })

    (mkIf brokerCfg.enable {
      services.dbus.enable = lib.mkOverride 75 false;  # 50 is force prio and 100 is default prio

      environment.systemPackages = [
        pkgs.dbus-broker
      ];

      systemd.packages = [
        pkgs.dbus-broker
      ];

      # Just to be sure we don't restart through the unit alias
      systemd.services.dbus.reloadIfChanged = true;
      systemd.user.services.dbus.reloadIfChanged = true;

      # NixOS Systemd Module doesn't respect 'Install'
      # https://github.com/NixOS/nixpkgs/issues/108643
      systemd.services.dbus-broker = {
        aliases = [
          "dbus.service"
        ];
        # Don't restart dbus. Bad things tend to happen if we do.
        reloadIfChanged = true;
        restartTriggers = [
          configDir
        ];
        environment = {
          LD_LIBRARY_PATH = config.system.nssModules.path;
        };
      };

      systemd.user.services.dbus-broker = {
        aliases = [
          "dbus.service"
        ];
        # Don't restart dbus. Bad things tend to happen if we do.
        reloadIfChanged = true;
        restartTriggers = [
          configDir
        ];
      };
    })

  ];
}
