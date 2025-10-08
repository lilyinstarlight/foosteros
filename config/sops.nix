{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.sops {
  sops = {
    age.sshKeyPaths = [];
    gnupg.sshKeyPaths = [ "${lib.optionalString config.preservation.enable config.system.devices.preservedState}/etc/ssh/ssh_host_rsa_key" ];
  };
}
