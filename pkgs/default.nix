{ pkgs ? import <nixpkgs> {}, fenix ? import <fenix> {}, ... } @ args:

with pkgs;

let mypkgs = let
  hasPath = attrset: path: lib.hasAttrByPath (lib.splitString "." path) attrset;
  resolvePath = attrset: path: lib.getAttrFromPath (lib.splitString "." path) attrset;
  resolveDep = path: if (args ? outpkgs) then (resolvePath args.outpkgs path) else if (hasPath mypkgs path) then (resolvePath mypkgs path) else (resolvePath pkgs path);

  # TODO: remove both when NixOS/nixpkgs#187636 is merged
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
  # normal packages
  dnsimple-ddns = callPackage ./dnsimple-ddns {};
  fooster-backgrounds = callPackage ./backgrounds {};
  fooster-materia-theme = callPackage ./materia-theme {};
  fpaste = python3Packages.callPackage ./fpaste {};
  ftmp = python3Packages.callPackage ./ftmp {};
  furi = python3Packages.callPackage ./furi {};
  google-10000-english = callPackage ./google-10000-english {};
  logmail = callPackage ./logmail {};
  mkusb = callPackage ./mkusb {
    syslinux = resolveDep "${if stdenv.isx86_64 then "" else "pkgsCross.gnu64."}syslinux";
  };
  mkwin = callPackage ./mkwin {};
  rofi-pass-wayland = callPackage ./rofi-pass-wayland {};
  sonic-pi_3 = libsForQt5.callPackage ./sonic-pi/v3.nix {};
  sonic-pi-tool = python3Packages.callPackage ./sonic-pi-tool {
    sonic-pi = resolveDep "sonic-pi_3";
  };

  # overridden packages
  # TODO: remove when there is a new release
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
  playdate-sdk = callPackage ./playdate-sdk {};
} // (if (args ? outpkgs) then {
  # TODO: remove when NixOS/nixpkgs#187636 is merged
  inherit python3Packages;
  inherit vimPlugins;
} else {
  # TODO: remove when NixOS/nixpkgs#187636 is merged
  python3Packages = recurseIntoAttrs (pkgs.python3Packages.callPackage ./python-modules {});
  vimPlugins = recurseIntoAttrs (callPackage ./vim-plugins {});
});

in mypkgs
