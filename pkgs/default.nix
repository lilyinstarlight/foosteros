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
  nixosTestFor = pkgs: config: (import "${toString pkgs.path}/nixos/lib" {}).runTest {
    imports = [ config ];
    hostPkgs = pkgs;
  };
  nixosTest = nixosTestFor outpkgs;

  # stdenvs
  tkeyStdenv = mkStdenvNoLibs (overrideCC llvmPackages_16.stdenv (llvmPackages_16.stdenv.cc.override (args: {
    bintools = buildPackages.llvmPackages_16.tools.bintools;
    nixSupport = (args.nixSupport or {}) // {
      cc-cflags = (args.nixSupport.cc-cflags or []) ++ [
        "-fno-stack-protector"
      ];
    };
  })));

  # normal packages
  awf-extended = callPackage ./awf-extended {};
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
  sonic-pi_3 = libsForQt5.callPackage ./sonic-pi/v3.nix {};
  sonic-pi-tool = python3Packages.callPackage ./sonic-pi-tool {
    sonic-pi = sonic-pi_3;
  };
  swaylock-fprintd = callPackage ./swaylock-fprintd {};
  tkey-libs = callPackage ./tkey-libs {};
  tkey-devtools = callPackage ./tkey-devtools {};
  tkey-sign = callPackage ./tkey-sign {};
  tkey-ssh-agent = callPackage ./tkey-ssh-agent {};
  tkey-device-signer = callPackage ./tkey-device-signer {};
  tkey-fido = callPackage ./tkey-fido {};
  tkey-random-generator = callPackage ./tkey-random-generator {};
  tkey-totp = callPackage ./tkey-totp {};
  tkey-verification = callPackage ./tkey-verification {};

  # overridden packages
  monofur-nerdfont = nerdfonts.override {
    fonts = [ "Monofur" ];
  };

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
