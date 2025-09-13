{ config, lib, pkgs, self, inputs, ... }:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  boot.kernelParams = lib.mkAfter [ "noquiet" ];

  # TODO: installer does not support systemd initrd yet, remove one line when NixOS/nixpkgs#291750 is merged
  boot.initrd.systemd.enable = lib.mkImageMediaOverride false;
  boot.initrd.systemd.emergencyAccess = lib.mkImageMediaOverride true;

  image.baseName = lib.mkImageMediaOverride
    "foosteros-${config.system.build.installHostname}-${config.system.nixos.release}-${self.shortRev or "dirty"}-${pkgs.stdenv.hostPlatform.uname.processor}";
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

        ${config.system.build.installDiskoScript or "echo 'No disko config, not partitioning automatically'"}

        mkdir -p /mnt/etc
        cp -rT ${self} /mnt/etc/nixos
        git -C /mnt/etc/nixos init
        git -C /mnt/etc/nixos add -N .
        git -C /mnt/etc/nixos remote add origin https://github.com/lilyinstarlight/foosteros.git
        (
          git -C /mnt/etc/nixos fetch && \
          git -C /mnt/etc/nixos reset ${self.rev or "origin/HEAD"} && \
          git -C /mnt/etc/nixos branch --set-upstream-to=origin/main main
        ) || true

        if nix eval "/mnt/etc/nixos#nixosConfigurations.$INSTALL_HOSTNAME.config.environment.persistence./state" >/dev/null; then
          mkdir -p /mnt/etc/ssh
          echo "Please enter the SSH RSA host key for $INSTALL_HOSTNAME and then press CTRL-D:"
          cat >/mnt/etc/ssh/ssh_host_rsa_key
          chmod u=rw,go= /mnt/etc/ssh/ssh_host_rsa_key
          ssh-keygen -y -f /mnt/etc/ssh/ssh_host_rsa_key >/mnt/etc/ssh/ssh_host_rsa_key.pub

          echo "Please enter the SSH ed25519 host key for $INSTALL_HOSTNAME and then press CTRL-D:"
          cat >/mnt/etc/ssh/ssh_host_ed25519_key
          chmod u=rw,go= /mnt/etc/ssh/ssh_host_ed25519_key
          ssh-keygen -y -f /mnt/etc/ssh/ssh_host_ed25519_key >/mnt/etc/ssh/ssh_host_ed25519_key.pub
        fi

        if nix eval "/mnt/etc/nixos#nixosConfigurations.$INSTALL_HOSTNAME.config.sops.secrets" >/dev/null; then
          mkdir -p /mnt/state/etc
          cp -a /mnt/etc/nixos /mnt/state/etc/
          if [ -e /mnt/etc/ssh ]; then
            mkdir -p /mnt/state/etc/ssh
            cp -a /mnt/etc/ssh/ssh_host_{rsa,ed25519}_key{,.pub} /mnt/state/etc/ssh/
          fi
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
