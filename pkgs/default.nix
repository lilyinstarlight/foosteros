{ pkgs ? import <nixpkgs> {}, fenix ? import <fenix> {}, ... } @ args:

let mypkgs = let
  outpkgs = if (args ? outpkgs) then args.outpkgs else pkgs.lib.recursiveUpdate pkgs mypkgs;

  callPackage = if (args ? outpkgs) then args.outpkgs.callPackage else (fn: args: pkgs.lib.callPackageWith (outpkgs // outpkgs.xorg) fn args);

  makeCallPackageScope = if (args ? outpkgs) then pkgs.lib.id else (scope: scope // {
    callPackage = fn: args: pkgs.lib.callPackageWith (outpkgs // outpkgs.xorg // scope) fn args;
  });

  python3Packages = makeCallPackageScope outpkgs.python3Packages;
  libsForQt5 = makeCallPackageScope outpkgs.libsForQt5;
in with outpkgs;

{
  # non-packages
  outPath = (toString ../.);
  makeTestPython = config: (import "${pkgs.path}/nixos/tests/make-test-python.nix" config { pkgs = outpkgs; system = stdenv.hostPlatform.system; }).test;

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
    syslinux = if stdenv.isx86_64 then syslinux else pkgsCross.gnu64.syslinux;
  };
  mkwin = callPackage ./mkwin {};
  rofi-pass-wayland = callPackage ./rofi-pass-wayland {};
  sonic-pi_3 = libsForQt5.callPackage ./sonic-pi/v3.nix {};
  sonic-pi-tool = python3Packages.callPackage ./sonic-pi-tool {
    sonic-pi = sonic-pi_3;
  };

  # TODO: remove after NixOS/nixpkgs#194310 is merged
  curl-impersonate = callPackage ./curl-impersonate {};

  # overridden packages
  # TODO: remove when tests fixed and added to nixpkgs
  mopidy-local = callPackage ./mopidy-local {
    inherit (pkgs) mopidy-local;
  };
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
  };

  # unfree packages
  playdate-sdk = callPackage ./playdate-sdk {};
} // (if (args ? outpkgs) then {
  vimPlugins = pkgs.vimPlugins.extend (self: super: callPackage ./vim-plugins {});
} else {
  # non-overlay lib inherits
  lib = {
    inherit (pkgs.lib) getVersion;
  };

  vimPlugins = recurseIntoAttrs (callPackage ./vim-plugins {});
});

in mypkgs
