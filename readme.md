# FoosterOS/2 Warp

_The totally cool way to run your computer_

Feel free to take any pieces in this repository that you would like! Please don't try to use this in its entirety, though, unless you are me. It is very custom and very specific to myself.


## Installation

1. Partition the disks with at least an EFI System Partition and preferably root and swap in an encrypted LVM.
2. Mount partitions under /mnt in the NixOS live install media.
3. Make parent directories and clone this repository into /mnt/etc/nixos.
4. Run nixos-install.
5. Reboot into the new system and login as root.
6. Set the password for user account "lily".
7. Logout and your FoosterOS/2 Warp system is setup and ready to go!
