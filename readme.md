# FoosterOS/2 Warp

_The totally cool way to run your computer_

Feel free to take any pieces in this repository that you like! Please don't try to use this whole thing, though, as it is horrifically custom and specific to myself.


[![FoosterOS/2 Warp Box Art](artwork/boxart.png)](https://www.os2world.com/wiki/images/7/7f/52H3800-004.jpg)


## Installation

NOTE: I have not tested these new instructions yet but I plan to soon!

1. Build then boot the relevant install media for the given system.
    ```
    nix -vL build --no-link --print-out-paths github:lilyinstarlight/foosteros#nixosConfigurations.minimal.config.system.build.isoImage
    ```
2. Run the customized install script from the install media.
    ```
    foosteros-install
    ```
3. Reboot into the new system.
    ```
    systemctl reboot
    ```

Your FoosterOS/2 Warp system is setup and ready to go!
