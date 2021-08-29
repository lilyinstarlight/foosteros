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

  vimPlugins = pkgs.vimPlugins.extend (self: super: callPackage ./vim-plugins {});
in

rec {
  crossguid = callPackage ./crossguid {};
  fooster-backgrounds = callPackage ./backgrounds {};
  fooster-materia-theme = callPackage ./materia-theme {};
  fpaste = python3Packages.callPackage ./fpaste {};
  ftmp = python3Packages.callPackage ./ftmp {};
  furi = python3Packages.callPackage ./furi {};
  gl3w = callPackage ./gl3w {};
  google-10000-english = callPackage ./google-10000-english {};
  mkusb = callPackage ./mkusb {};
  mkwin = callPackage ./mkwin {};
  open-stage-control = callPackage ./open-stage-control {};
  petty = callPackage ./petty {};
  platform-folders = callPackage ./platform-folders {};
  pridecat = callPackage ./pridecat {};
  rofi-pass-wayland = callPackage ./rofi-pass-wayland {
    rofi-wayland = if isOverlay then outpkgs.rofi-wayland else rofi-wayland;
    wtype = if isOverlay then outpkgs.wtype else wtype;
  };
  rofi-wayland = callPackage ./rofi-wayland {};
  sonic-pi-tool = python3Packages.callPackage ./sonic-pi-tool {
    supercollider = if isOverlay then outpkgs.supercollider-with-sc3-plugins else supercollider-with-sc3-plugins;
  };
  swaynag-battery = callPackage ./swaynag-battery {};

  sonic-pi = libsForQt5.callPackage ./sonic-pi {
    supercollider = if isOverlay then outpkgs.supercollider-with-sc3-plugins else supercollider-with-sc3-plugins;
  };
  sonic-pi-beta = libsForQt5.callPackage ./sonic-pi-beta {
    platform-folders = if isOverlay then outpkgs.platform-folders else platform-folders;
    supercollider = if isOverlay then outpkgs.supercollider-with-sc3-plugins else supercollider-with-sc3-plugins;
  };
  supercolliderPlugins = recurseIntoAttrs {
    sc3-plugins = callPackage ./supercollider/sc3-plugins {
      fftw = outpkgs.fftwSinglePrec;
      supercollider = if isOverlay then outpkgs.supercollider else supercollider;
    };
  };
  supercollider = libsForQt5.callPackage ./supercollider {
    fftw = outpkgs.fftwSinglePrec;
  };
  supercollider-with-sc3-plugins = (if isOverlay then outpkgs.supercollider else supercollider).override {
    plugins = with supercolliderPlugins; [ sc3-plugins ];
  };
  wtype = callPackage ./wtype {
    inherit (pkgs) wtype;
  };

  monofur-nerdfont = nerdfonts.override {
    fonts = [ "Monofur" ];
  };

  pass-wayland-otp = (pass-wayland.withExtensions (ext: [ ext.pass-otp ])).overrideAttrs (attrs: {
    meta = with lib; attrs.meta // {
      platforms = platforms.linux;
    };
  });
} // (if isOverlay then {
  inherit python3Packages vimPlugins;
} else {
  python3Packages = recurseIntoAttrs (callPackage ./python-modules {});
  vimPlugins = recurseIntoAttrs (callPackage ./vim-plugins {});
}) // (lib.optionalAttrs allowUnfree {
})
