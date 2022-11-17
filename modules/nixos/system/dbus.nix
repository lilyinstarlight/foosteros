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

{ config, lib, pkgs, ... }:

let

  cfg = config.services.dbus;

  homeDir = "/run/dbus";

  configDir = pkgs.makeDBusConf {
    inherit (cfg) apparmor;
    suidHelper = "${config.security.wrapperDir}/dbus-daemon-launch-helper";
    serviceDirectories = cfg.packages;
  };

  inherit (lib) mkOption types;

in

{
  disabledModules = [ "services/system/dbus.nix" ];

  options = {

    services.dbus = {

      enable = mkOption {
        type = types.bool;
        default = true;
        internal = true;
        description = lib.mdDoc ''
          Whether to start the D-Bus message bus daemon, which is
          required by many other system services and applications.
        '';
      };

      implementation = mkOption {
        type = types.enum [ "dbus" "broker" ];
        default = "dbus";
        description = lib.mdDoc ''
          The implementation to use for the message bus defined by the D-Bus specification.
          Can be either the classic dbus daemon or dbus-broker, which aims to provide high
          performance and reliability, while keeping compatibility to the D-Bus
          reference implementation.
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
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable (lib.mkMerge [
    ({
      environment.systemPackages = [
        pkgs.dbus
      ];

      environment.etc."dbus-1".source = configDir;

      users.users.messagebus = {
        uid = config.ids.uids.messagebus;
        description = "D-Bus system message bus daemon user";
        home = homeDir;
        group = "messagebus";
      };

      users.groups.messagebus.gid = config.ids.gids.messagebus;

      systemd.packages = [
        pkgs.dbus
      ];

      services.dbus.packages = [
        pkgs.dbus
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

    (lib.mkIf (cfg.implementation == "dbus") {
      environment.systemPackages = [
        pkgs.dbus
      ];

      security.wrappers.dbus-daemon-launch-helper = {
        source = "${pkgs.dbus}/libexec/dbus-daemon-launch-helper";
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

    (lib.mkIf (cfg.implementation == "broker") {
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
  ]);
}
