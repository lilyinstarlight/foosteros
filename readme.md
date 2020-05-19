# FoosterOS/2 Warp

_The totally cool way to run your computer_

Feel free to take any pieces in this repository that you would like! Please don't try to use this in its entirety, though, unless you are me. It is very custom and very specific to myself.


## Installation

1. Boot NixOS minimal install media.
2. Partition the disks with at least an EFI System Partition and preferably root and swap in an encrypted LVM.
    ```
    sgdisk -og /dev/sda
    sgdisk -n 1:0:+512M -c 1:esp -t 1:ef00 /dev/sda
    sgdisk -n 2:0:0 -c 2:nixos -t 2:8e00 /dev/sda
    mkfs.fat -F32 -n esp /dev/sda1
    cryptsetup luksFormat /dev/sda2
    cryptsetup open /dev/sda2 nixos
    pvcreate /dev/mapper/nixos
    vgcreate nixos /dev/mapper/nixos
    lvcreate -L $(expr $(vgs -o vg_size --noheadings --units g --nosuffix nixos) - 2)g -n root nixos
    mkfs.btrfs -L root
    lvcreate -l 100%FREE -n swap nixos
    mkswap -L swap /dev/mapper/nixos-swap
    ```
3. Mount partitions under /mnt.
    ```
    swapon /dev/mapper/nixos-swap
    mkdir -p /mnt
    mount /dev/mapper/nixos-root /mnt
    mkdir -p /mnt/boot
    mount /dev/sda1 /mnt/boot
    ```
4. Make parent directories and clone this repository into /mnt/etc/nixos.
    ```
    mkdir -p /mnt/etc
    git clone https://github.com/fkmclane/foosteros.git /mnt/etc/nixos
    ```
5. Symlink configuration.nix and hardware-configuration.nix from the target system under hosts to /etc/nixos (hardware-configuration.nix can be generated if desired).
    ```
    ln -s hosts/bina/configuration.nix /mnt/etc/nixos/configuration.nix
    ln -s hosts/bina/hardware-configuration.nix /mnt/etc/nixos/hardware-configuration.nix
    ```
6. Run nixos-install.
    ```
    nixos-install
    ```
7. Reboot into the new system and login as root.
    ```
    systemctl reboot
    ```
8. Set the password for user account "lily".
    ```
    passwd lily
    ```
9. Logout and your FoosterOS/2 Warp system is setup and ready to go!
