{ pkgs ? import <nixpkgs> {}, ... } @ args:

let mypkgs = let
  outpkgs = if (args ? outpkgs) then args.outpkgs else pkgs.lib.recursiveUpdate pkgs mypkgs;

  callPackage = if (args ? outpkgs) then args.outpkgs.callPackage else let
    callPackage = pkgs.lib.callPackageWith (outpkgs // { inherit callPackage; });
  in callPackage;

  makeCallPackageScope = if (args ? outpkgs) then pkgs.lib.id else (scope: let
    callPackage = pkgs.lib.callPackageWith (outpkgs // scope // { inherit callPackage; });
  in scope // { inherit callPackage; });

  python3Packages = makeCallPackageScope outpkgs.python3Packages;
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
  tkeyStdenv = mkStdenvNoLibs (overrideCC llvmPackages.stdenv (llvmPackages.stdenv.cc.override (args: {
    bintools = buildPackages.llvmPackages.bintools.override {
      defaultHardeningFlags = lib.subtractLists [ "stackprotector" "zerocallusedregs" ] buildPackages.llvmPackages.bintools.defaultHardeningFlags;
    };
    nixSupport = (args.nixSupport or {}) // {
      cc-cflags = (args.nixSupport.cc-cflags or []) ++ [
        "-fno-asynchronous-unwind-tables"
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
  swaylock-fprintd = callPackage ./swaylock-fprintd {};
  tkey-libs = callPackage ./tkey-libs {};
  tkey-devtools = callPackage ./tkey-devtools {};
  tkey-sign = callPackage ./tkey-sign {};
  tkey-ssh-agent = callPackage ./tkey-ssh-agent {};
  tkey-device-signer = callPackage ./tkey-device-signer {};
  tkey-fido = callPackage ./tkey-fido {};
  tkey-random-generator = callPackage ./tkey-random-generator {};
  tkey-verification = callPackage ./tkey-verification {};

  # dependents of unfree packages
  crank = callPackage ./crank {};

  # unfree packages
  playdate-sdk = callPackage ./playdate-sdk {};

  # TODO: remove when xdp-wlr supports RemoteDesktop portal
  xdg-desktop-portal-wlr = pkgs.xdg-desktop-portal-wlr.overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      (fetchurl {
        name = "xdp-wlr-remotedesktop.patch";
        url = "https://github.com/emersion/xdg-desktop-portal-wlr/compare/e34a77ec7e5c3a5f2807282338a2f25964bd98d7~1..bdd26ad0096290e1cc9a952e18732e8544f783bc.diff";
        hash = "sha256-osIh5S9YpePRLJ1TCkj+DacAFqiKYM5keYkXiSwQ57w=";
      })
    ];

    buildInputs = (old.buildInputs or []) ++ [
      libxkbcommon
    ];
  });
} // (if (args ? outpkgs) then {
  vimPlugins = pkgs.vimPlugins.extend (self: super: callPackage ./vim-plugins {});
} else {
  # non-overlay lib inherits
  lib = {
    inherit (pkgs.lib) getVersion;
  };

  vimPlugins = pkgs.lib.recurseIntoAttrs (callPackage ./vim-plugins {});
});

in mypkgs
