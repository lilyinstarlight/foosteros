# FoosterOS/2 Warp

_The totally cool way to run your computer_

Feel free to take any pieces in this repository that you like! Please don't try to use this whole thing, though, as it is horrifically custom and specific to myself.


[![FoosterOS/2 Warp Box Art](artwork/boxart.png)](https://www.os2world.com/wiki/images/7/7f/52H3800-004.jpg)


## Installation

**Note:** I made this install script for myself. You can use it if you really want to, but be aware that it **will** entirely wipe your computer's disk as part of the install process.

1. Build or [download](https://file.lily.flowers/foosteros/iso/) then boot the relevant install media for the given system.
    ```
    # NOTE: Only if not downloading
    nix -vL build --no-link --print-out-paths \
      github:lilyinstarlight/foosteros#nixosConfigurations.minimal.config.system.build.isoImage
    ```
2. Run the customized install script from the install media.
    ```
    sudo foosteros-install
    ```
3. Reboot into the new system.
    ```
    sudo systemctl reboot
    ```

Your FoosterOS/2 Warp system is setup and ready to go!
