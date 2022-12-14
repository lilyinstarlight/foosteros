{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  boot.kernelParams = lib.mkAfter [ "noquiet" ];

  # TODO: installer does not support systemd initrd yet
  boot.initrd.systemd.enable = lib.mkImageMediaOverride false;

  isoImage.isoName = lib.mkForce "foosteros.iso";

  environment.systemPackages = with pkgs; [
    (writeShellApplication {
      name = "foosteros-install";
      runtimeInputs = [ nix openssh git ];
      text = ''
        hostname="${config.system.build.installHostname}"

        ${config.system.build.installDisko}

        mkdir -p /mnt/etc
        git clone https://github.com/lilyinstarlight/foosteros.git /mnt/etc/nixos

        if nix eval /mnt/etc/nixos#nixosConfigurations."$hostname".config.environment.persistenence./state >/dev/null; then
          mkdir -p /mnt/etc/ssh
          echo "Please enter the SSH host key for $hostname and then press CTRL-D:"
          cat >/mnt/etc/ssh/ssh_host_rsa_key
          ssh-keygen -y -f /mnt/etc/ssh/ssh_host_rsa_key >/mnt/etc/ssh/ssh_host_rsa_key.pub
          chmod u=rw,go= /mnt/etc/ssh/ssh_host_rsa_key

          mkdir -p /mnt/state/etc
          cp -a /mnt/etc/nixos /mnt/state/etc/
          mkdir -p /mnt/state/etc/ssh
          cp -a /mnt/etc/ssh/ssh_host_rsa_key{,.pub} /mnt/state/etc/ssh/
        fi

        installArgs=(--no-channel-copy)

        if [ "$(nix eval /mnt/etc/nixos#nixosConfigurations."$hostname".config.users.mutableUsers)" = "false" ]; then
          installArgs+=(--no-root-password)
        fi

        nixos-install --flake "/mnt/etc/nixos#$hostname" "''${installArgs[@]}"
      '';
    })
  ];
}
