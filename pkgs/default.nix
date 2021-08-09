{ pkgs, outpkgs ? pkgs, allowUnfree ? (!(builtins.getEnv "FOOSTEROS_EXCLUDE_UNFREE" == "1")), isOverlay ? true, ... }:

with pkgs;

let
  python3 = let
    self = pkgs.python3.override {
      packageOverrides = (self: super: super.pkgs.callPackage ./python-modules {});
      inherit self;
    };
  in self;
  python3Packages = recurseIntoAttrs python3.pkgs;

  libsForQt5 = pkgs.libsForQt5 // {
    drumstick = pkgs.libsForQt5.callPackage ./drumstick { inherit (pkgs.libsForQt5) drumstick; };
  };

  vimPlugins = pkgs.vimPlugins.extend (self: super: callPackage ./vim-plugins {});
in

rec {
  fooster-backgrounds = callPackage ./backgrounds {};
  fooster-materia-theme = callPackage ./materia-theme {};
  fpaste = python3Packages.callPackage ./fpaste {};
  ftmp = python3Packages.callPackage ./ftmp {};
  furi = python3Packages.callPackage ./furi {};
  google-10000-english = callPackage ./google-10000-english {};
  mkusb = callPackage ./mkusb {};
  mkwin = callPackage ./mkwin {};
  open-stage-control = callPackage ./open-stage-control {};
  petty = callPackage ./petty {};
  pridecat = callPackage ./pridecat {};
  rofi-pass-wayland = callPackage ./rofi-pass-wayland {
    rofi-wayland = if isOverlay then outpkgs.rofi-wayland else rofi-wayland;
    wtype = if isOverlay then outpkgs.wtype else wtype;
  };
  rofi-wayland = callPackage ./rofi-wayland {};
  sonic-pi-tool = python3Packages.callPackage ./sonic-pi-tool {};
  swaynag-battery = callPackage ./swaynag-battery {};

  sonic-pi = libsForQt5.callPackage ./sonic-pi {};
  vmpk = libsForQt5.callPackage ./vmpk {
    drumstick = if isOverlay then outpkgs.libsForQt5.drumstick else libsForQt5.drumstick;
    inherit (pkgs) vmpk;
  };
  wtype = callPackage ./wtype {
    inherit (pkgs) wtype;
  };

  monofur-nerdfont = nerdfonts.override {
    fonts = [ "Monofur" ];
  };

  pass-wayland-otp = pass-wayland.withExtensions (ext: [ ext.pass-otp ]);
} // (if isOverlay then {
  inherit python3Packages libsForQt5 vimPlugins;
} else {
  python3Packages = recurseIntoAttrs (callPackage ./python-modules {});
  libsForQt5 = recurseIntoAttrs {
    drumstick = pkgs.libsForQt5.callPackage ./drumstick { inherit (pkgs.libsForQt5) drumstick; };
  };
  vimPlugins = recurseIntoAttrs (callPackage ./vim-plugins {});
}) // (lib.optionalAttrs allowUnfree {
})
