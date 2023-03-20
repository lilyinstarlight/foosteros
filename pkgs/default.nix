{ pkgs ? import <nixpkgs> {}, ... } @ args:

let mypkgs = let
  outpkgs = if (args ? outpkgs) then args.outpkgs else pkgs.lib.recursiveUpdate pkgs mypkgs;

  callPackage = if (args ? outpkgs) then args.outpkgs.callPackage else let
    callPackage = pkgs.lib.callPackageWith (outpkgs // outpkgs.xorg // { inherit callPackage; });
  in callPackage;

  makeCallPackageScope = if (args ? outpkgs) then pkgs.lib.id else (scope: let
    callPackage = pkgs.lib.callPackageWith (outpkgs // outpkgs.xorg // scope // { inherit callPackage; });
  in scope // { inherit callPackage; });

  python3Packages = makeCallPackageScope outpkgs.python3Packages;
  libsForQt5 = makeCallPackageScope outpkgs.libsForQt5;
in with outpkgs;

{
  # non-packages
  outPath = (toString ../.);
  nixosTestFor = pkgs: config:
    (import "${pkgs.path}/nixos/tests/make-test-python.nix"
      (if lib.isPath config then import config else config) {
        inherit pkgs;
        inherit (pkgs.stdenv.hostPlatform) system;
      }).test;
  nixosTest = nixosTestFor outpkgs;

  # normal packages
  dnsimple-ddns = callPackage ./dnsimple-ddns {};
  fooster-backgrounds = callPackage ./backgrounds {};
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
  swaylock-fprintd = callPackage ./swaylock-fprintd {};

  # TODO: remove after NixOS/nixpkgs#194310 is merged
  curl-impersonate = callPackage ./curl-impersonate {};

  # TODO: remove after NixOS/nixpkgs#222179 is merged
  open-stage-control = pkgs.open-stage-control.overrideAttrs (attrs: rec {
    version = "1.23.0";
    src = fetchFromGitHub {
      owner = "jean-emmanuel";
      repo = "open-stage-control";
      rev = "v${version}";
      hash = "sha256-5QMBJw6H9TmyoSMkG5rniq1BdVYuEtQsQF1GGBkxqMI=";
    };
  });

  # overridden packages
  monofur-nerdfont = nerdfonts.override {
    fonts = [ "Monofur" ];
  };

  pass-wayland-otp = (pass-wayland.withExtensions (ext: [ ext.pass-otp ])).overrideAttrs (attrs: {
    meta = with lib; attrs.meta // {
      platforms = platforms.linux;
    };
  });

  # dependents of unfree packages
  crank = callPackage ./crank {};

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
