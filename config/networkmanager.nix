{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.networkmanager {
  # TODO: fix bug in nixpkgs wpa_supplicant module properly
  services.udev.extraRules = lib.mkAfter ''
      ACTION=="add|remove", SUBSYSTEM=="net", ENV{DEVTYPE}=="wlan", RUN="${lib.getExe' pkgs.coreutils "true"}"
      ACTION=="add|remove", SUBSYSTEM=="net", ENV{DEVTYPE}=="wlan", ENV{INTERFACE}!="p2p-*", RUN+="${lib.getExe' config.system.path "systemctl"} try-restart wpa_supplicant.service"
  '';

  # TODO: make better fix for this bus policy gap for fi.w1.wpa_supplicant1->org.freedesktop.NetworkManager signals
  services.dbus.packages = lib.mkAfter (with pkgs; [
    (writeTextDir "share/dbus-1/system.d/nm-wpas.conf" ''
        <!DOCTYPE busconfig PUBLIC
         "-//freedesktop//DTD D-BUS Bus Configuration 1.0//EN"
         "http://www.freedesktop.org/standards/dbus/1.0/busconfig.dtd">
        <busconfig>
            <policy user="wpa_supplicant">
                <allow send_destination="org.freedesktop.NetworkManager" send_type="signal"/>
            </policy>
        </busconfig>
    '')
  ]);

  networking.networkmanager = {
    enable = true;
    wifi.powersave = true;
    unmanaged = [
      "interface-name:vir*"
    ];
  };
}
