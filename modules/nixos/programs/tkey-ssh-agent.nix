{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.tkey-ssh-agent;
in

{
  options.programs.tkey-ssh-agent = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc ''
        Whether to enable a user service for tkey-ssh-agent.
      '';
    };

    install = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc ''
        Whether to install a user service for tkey-ssh-agent.

        The service must be manually started for each user with
        `systemctl --user start tkey-ssh-agent` or globally through
        {option}`programs.tkey-ssh-agent.enable`.
      '';
    };

    package = mkOption {
      type = types.package;
      default = pkgs.tkey-ssh-agent;
      defaultText = literalExpression "pkgs.tkey-ssh-agent";
      description = mdDoc ''
        tkey-ssh-agent derivation to use.
      '';
    };

    socket = mkOption {
      type = types.str;
      default = "\${XDG_RUNTIME_DIR}/ssh-agent";
      description = mdDoc ''
        Socket path for SSH agent to listen on.
      '';
    };

    userSuppliedSecret = mkOption {
      type = types.bool;
      default = false;
      description = mdDoc ''
        Whether to enable typing a User Supplied Secret for SSH keys.
      '';
    };
  };

  config = mkIf (cfg.enable || cfg.install) {
    systemd.user.services.tkey-ssh-agent = {
      description = "TKey SSH Agent";
      partOf = [ "default.target" ];

      path = [ pkgs.sway ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/tkey-ssh-agent ${lib.optionalString cfg.userSuppliedSecret "--uss ${lib.optionalString (config.programs.gnupg.agent.settings ? pinentry-program) "--pinentry ${config.programs.gnupg.agent.settings.pinentry-program}"}"} --agent-socket ${cfg.socket}";
      };
    } // optionalAttrs cfg.enable {
      wantedBy = [ "default.target" ];
    };

    environment.extraInit = lib.optionalString cfg.enable ''
      if [ -z "$SSH_AUTH_SOCK" ]; then
        export SSH_AUTH_SOCK="${cfg.socket}"
      fi
    '';

    environment.systemPackages = [ cfg.package ];
  };
}
