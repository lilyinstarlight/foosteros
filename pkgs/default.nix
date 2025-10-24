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
  tkeyStdenv = mkStdenvNoLibs (overrideCC llvmPackages_18.stdenv (llvmPackages_18.stdenv.cc.override (args: {
    bintools = buildPackages.llvmPackages_18.tools.bintools.override {
      defaultHardeningFlags = lib.subtractLists [ "stackprotector" "zerocallusedregs" ] buildPackages.llvmPackages_18.tools.bintools.defaultHardeningFlags;
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
  tkey-totp = callPackage ./tkey-totp {};
  tkey-verification = callPackage ./tkey-verification {};

  # TODO: remove when slurp or wlroots or sway fixes this
  slurp = pkgs.slurp.overrideAttrs (old: {
    patches = old.patches or [] ++ [
      # https://github.com/emersion/slurp/pull/124
      (fetchpatch {
        name = "slurp-fix-segfault.patch";
        url = "https://github.com/emersion/slurp/compare/6a21ddcdde33affc74f45bcd322292db90984293~1...820041f4f17437b16701c16deed5f2188d9b4993.diff";
        hash = "sha256-uVJ/7ycGxPNoawXbGYjR5YZ8AZCWiPiYLeFHSlHkKT8=";
      })
    ];
  });

  # TODO: remove when xdg-desktop-portal-wlr fixes upstream bitmasking error
  xdg-desktop-portal-wlr = pkgs.xdg-desktop-portal-wlr.overrideAttrs (old: {
    patches = old.patches or [] ++ [
      # https://github.com/emersion/xdg-desktop-portal-wlr/pull/309
      (fetchpatch {
        name = "xdg-desktop-portal-wlr-fix-screencast-select-sources.patch";
        url = "https://github.com/emersion/xdg-desktop-portal-wlr/commit/d9ada849aeca6137915de2df69beaef4e272cc1d.diff";
        hash = "sha256-iyjdKOyh1uZGu7T1SRc5Nwlr5nnfV6eI4eKeBl3hlf8=";
      })
    ];
  });

  # TODO: remove when NixOS/nixpkgs#454910 is fixed
  qgnomeplatform-qt6 = pkgs.qgnomeplatform-qt6.overrideAttrs (old: {
    patches = (old.patches or []) ++ [
      (pkgs.writeText "qgnomeplatform-qt6-guiprivate.patch" ''
        diff --git a/CMakeLists.txt b/CMakeLists.txt
        index cc0b067..2c9d191 100644
        --- a/CMakeLists.txt
        +++ b/CMakeLists.txt
        @@ -26,7 +26,7 @@ include(GNUInstallDirs)
         include(FeatureSummary)

         if (USE_QT6)
        -    find_package(QT NAMES Qt6 COMPONENTS Core DBus Gui Widgets REQUIRED)
        +    find_package(QT NAMES Qt6 COMPONENTS Core DBus Gui Widgets REQUIRED GuiPrivate)
         else()
        -    find_package(QT NAMES Qt5 COMPONENTS Core DBus Gui Widgets REQUIRED)
        +    find_package(QT NAMES Qt5 COMPONENTS Core DBus Gui Widgets REQUIRED GuiPrivate)
         endif()
      '')
    ];
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
