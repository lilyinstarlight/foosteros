{ config, lib, pkgs, fpkgs ? pkgs, ... }:

let
  cfg = config.programs.tkey-ssh-agent;
in

{
  options.programs.tkey-ssh-agent = {
    enable = lib.mkEnableOption "user service for tkey-ssh-agent";

    install = lib.mkEnableOption "user service for tkey-ssh-agent" // {
      description = ''
        Whether to install a user service for tkey-ssh-agent.

        The service must be manually started for each user with
        `systemctl --user start tkey-ssh-agent` or globally through
        {option}`programs.tkey-ssh-agent.enable`.
      '';
    };

    package = lib.mkPackageOption fpkgs "tkey-ssh-agent" {
      pkgsText = "fpkgs";
    };

    socket = lib.mkOption {
      type = lib.types.str;
      default = "\${XDG_RUNTIME_DIR}/ssh-agent";
      description = ''
        Socket path for SSH agent to listen on.
      '';
    };

    userSuppliedSecret = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable typing a User Supplied Secret for SSH keys.
      '';
    };
  };

  config = lib.mkIf (cfg.enable || cfg.install) {
    systemd.user.services.tkey-ssh-agent = {
      description = "TKey SSH Agent";
      partOf = [ "default.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe cfg.package} ${lib.optionalString cfg.userSuppliedSecret "--uss ${lib.optionalString (config.programs.gnupg.agent.settings ? pinentry-program) "--pinentry ${config.programs.gnupg.agent.settings.pinentry-program}"}"} --agent-socket ${cfg.socket}";
      };
    } // lib.optionalAttrs cfg.enable {
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
