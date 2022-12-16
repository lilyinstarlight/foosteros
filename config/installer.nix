{ config, lib, pkgs, self, inputs, ... }:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    ./networking.nix
  ];

  boot.kernelParams = lib.mkAfter [ "noquiet" ];

  # TODO: installer does not support systemd initrd yet
  boot.initrd.systemd.enable = lib.mkImageMediaOverride false;

  isoImage.isoName = lib.mkImageMediaOverride "foosteros-${config.system.build.installHostname}.iso";
  isoImage.volumeID = "foosteros-${config.system.nixos.release}-${self.shortRev or "dirty"}-${pkgs.stdenv.hostPlatform.uname.processor}";

  networking.hostName = lib.mkImageMediaOverride "${config.system.build.installHostname}-installer";

  environment.systemPackages = with pkgs; [
    (writeShellApplication {
      name = "foosteros-install";
      runtimeInputs = [ nix openssh git ];
      text = ''
        set -euxo pipefail

        export SYSTEM_CLOSURE='${config.system.build.installClosure}'
        export INSTALL_HOSTNAME='${config.system.build.installHostname}'

        which foosteros-prepare &>/dev/null && foosteros-prepare

        ${config.system.build.installDisko or "echo 'No disko config, not partitioning automatically'"}

        mkdir -p /mnt/etc
        git clone https://github.com/lilyinstarlight/foosteros.git /mnt/etc/nixos
        git -C /mnt/etc/nixos reset --hard ${self.rev or "origin/HEAD"}

        if nix eval "/mnt/etc/nixos#nixosConfigurations.$INSTALL_HOSTNAME.config.environment.persistence./state" >/dev/null; then
          mkdir -p /mnt/etc/ssh
          echo "Please enter the SSH host key for $INSTALL_HOSTNAME and then press CTRL-D:"
          cat >/mnt/etc/ssh/ssh_host_rsa_key
          chmod u=rw,go= /mnt/etc/ssh/ssh_host_rsa_key
          ssh-keygen -y -f /mnt/etc/ssh/ssh_host_rsa_key >/mnt/etc/ssh/ssh_host_rsa_key.pub

          mkdir -p /mnt/state/etc
          cp -a /mnt/etc/nixos /mnt/state/etc/
          mkdir -p /mnt/state/etc/ssh
          cp -a /mnt/etc/ssh/ssh_host_rsa_key{,.pub} /mnt/state/etc/ssh/
        fi

        installArgs=(--no-channel-copy)

        if [ "$(nix eval "/mnt/etc/nixos#nixosConfigurations.$INSTALL_HOSTNAME.config.users.mutableUsers")" = "false" ]; then
          installArgs+=(--no-root-password)
        fi

        nixos-install --flake "/mnt/etc/nixos#$INSTALL_HOSTNAME" "''${installArgs[@]}"
      '';
    })
  ];
}
