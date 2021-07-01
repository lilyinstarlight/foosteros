# FoosterOS/2 Warp

_The totally cool way to run your computer_

Feel free to take any pieces in this repository that you like! Please don't try to use this whole thing, though, as it is horrifically custom and specific to myself.


![FoosterOS/2 Warp Box Art](artwork/boxart.png)


## Installation

1. Boot NixOS minimal install media.
2. Add installation dependencies such as unstable Nix (for flakes), bc, and git.
    ```
    nix-env -iA nixos.{nixUnstable,bc,git}
    ```
3. Partition the disks with at least an EFI System Partition and preferably root and swap in an encrypted LVM.
    ```
    sgdisk -og /dev/sda
    sgdisk -n 1:0:+512M -c 1:esp -t 1:ef00 /dev/sda
    sgdisk -n 2:0:0 -c 2:nixos -t 2:8e00 /dev/sda
    mkfs.fat -F32 -n esp /dev/sda1
    cryptsetup luksFormat /dev/sda2
    cryptsetup open /dev/sda2 nixos
    pvcreate /dev/mapper/nixos
    vgcreate nixos /dev/mapper/nixos
    lvcreate -L "$(echo 'scale = 2;' "$(vgs -o vg_size --noheadings --units g --nosuffix nixos)" - "$(echo 'scale = 0;' '(' "$(grep -F MemTotal: /proc/meminfo | awk '{print $2}')" + 1024 '*' 1024 ')' / '(' 1024 '*' 1024 ')' | bc)" | bc)"g -n root nixos
    mkfs.btrfs -L root /dev/mapper/nixos-root
    lvcreate -l 100%FREE -n swap nixos
    mkswap -L swap /dev/mapper/nixos-swap
    ```
4. Mount partitions under /mnt.
    ```
    swapon /dev/disk/by-label/swap
    mkdir -p /mnt
    mount /dev/disk/by-label/root /mnt
    mkdir -p /mnt/boot
    mount /dev/disk/by-label/esp /mnt/boot
    ```
5. Make parent directories and clone this repository into /mnt/etc/nixos.
    ```
    mkdir -p /mnt/etc
    git clone https://github.com/lilyinstarlight/foosteros.git /mnt/etc/nixos
    ```
6. Run nixos-install for the target host.
    ```
    # NOTE: Not working (ref: https://github.com/NixOS/nix/issues/4081)
    # nixos-install --flake '/mnt/etc/nixos#bina' --no-channel-copy
    # NOTE: Temporary replacement
    nix --experimental-features 'nix-command flakes' build --no-link /mnt/etc/nixos#nixosConfigurations.bina.config.system.build.toplevel | xargs -I'{}' nixos-install --system '{}'
    ```
7. Set the password for user account "lily".
    ```
    nixos-enter --root /mnt
    passwd lily
    exit
    ```
8. Reboot into the new system.
    ```
    systemctl reboot
    ```

Your FoosterOS/2 Warp system is setup and ready to go!
