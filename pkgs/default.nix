{ pkgs ? import <nixpkgs> {}, outpkgs ? pkgs, fenix ? import <fenix> {}, allowUnfree ? (!(builtins.getEnv "FOOSTEROS_EXCLUDE_UNFREE" == "1")), isOverlay ? false, ... }:

with pkgs;

let mypkgs = let
  hasPath = attrset: path: lib.hasAttrByPath (lib.splitString "." path) attrset;
  resolvePath = attrset: path: lib.getAttrFromPath (lib.splitString "." path) attrset;
  resolveDep = path: if isOverlay then (resolvePath outpkgs path) else if (hasPath mypkgs path) then (resolvePath mypkgs path) else (resolvePath pkgs path);

  python3 = let
    self = pkgs.python3.override {
      packageOverrides = (self: super: super.pkgs.callPackage ./python-modules {});
      inherit self;
    };
  in self;
  python3Packages = recurseIntoAttrs python3.pkgs;

  vimPlugins = pkgs.vimPlugins.extend (self: super: callPackage ./vim-plugins {});
in

{
  dnsimple-ddns = callPackage ./dnsimple-ddns {};
  fooster-backgrounds = callPackage ./backgrounds {};
  fooster-materia-theme = callPackage ./materia-theme {};
  fpaste = python3Packages.callPackage ./fpaste {};
  ftmp = python3Packages.callPackage ./ftmp {};
  furi = python3Packages.callPackage ./furi {};
  google-10000-english = callPackage ./google-10000-english {};
  logmail = callPackage ./logmail {};
  mkusb = callPackage ./mkusb {};
  mkwin = callPackage ./mkwin {};
  nix-index-database = callPackage ./nix-index-database {};
  petty = callPackage ./petty {};
  pridecat = callPackage ./pridecat {};
  rofi-pass-wayland = callPackage ./rofi-pass-wayland {
    rofi-wayland = resolveDep "rofi-wayland";
  };
  sonic-pi_3 = libsForQt5.callPackage ./sonic-pi/v3.nix {};
  sonic-pi-tool = python3Packages.callPackage ./sonic-pi-tool {
    sonic-pi = resolveDep "sonic-pi_3";
  };

  mpdris2 = callPackage ./mpdris2 {
    inherit (pkgs) mpdris2;
  };

  monofur-nerdfont = nerdfonts.override {
    fonts = [ "Monofur" ];
  };

  pass-wayland-otp = (pass-wayland.withExtensions (ext: [ ext.pass-otp ])).overrideAttrs (attrs: {
    meta = with lib; attrs.meta // {
      platforms = platforms.linux;
    };
  });

  # TODO: remove when NixOS/nixpkgs#170464 is merged
  open-stage-control = callPackage ./open-stage-control {
    electron = resolveDep "electron_15";
    nodejs = resolveDep "nodejs-16_x";
  };

  # TODO: remove when NixOS/nixpkgs#xxxxxx is merged
  kissfftFloat = kissfft.override { datatype = "float"; };
  crossguid = callPackage ./crossguid {};
  gl3w = callPackage ./gl3w {};
  platform-folders = callPackage ./platform-folders {};
  sonic-pi = libsForQt5.callPackage ./sonic-pi {
    kissfftFloat = resolveDep "kissfftFloat";
    crossguid = resolveDep "crossguid";
    gl3w = resolveDep "gl3w";
    platform-folders = resolveDep "platform-folders";
  };
} // (if isOverlay then {
  inherit nodePackages python3Packages vimPlugins;
} else {
  python3Packages = recurseIntoAttrs (pkgs.python3Packages.callPackage ./python-modules {});
  vimPlugins = recurseIntoAttrs (callPackage ./vim-plugins {});
}) // (lib.optionalAttrs allowUnfree {
  # dependents of unfree packages
  crank = callPackage ./crank {
    rustNightlyToolchain = fenix.complete.withComponents [
      "rustc"
      "cargo"
      "rust-src"
    ];
    playdate-sdk = resolveDep "playdate-sdk";
  };

  # unfree packages
  kodelife = callPackage ./kodelife {
    inherit (gst_all_1) gstreamer gst-plugins-base;
  };
  playdate-sdk = callPackage ./playdate-sdk {};
  touchosc = callPackage ./touchosc {};
});

in mypkgs
