{ pkgs ? import <nixpkgs> {}, outpkgs ? pkgs, fenix ? import <fenix> {}, allowUnfree ? (!(builtins.getEnv "FOOSTEROS_EXCLUDE_UNFREE" == "1")), isOverlay ? false, ... }:

with pkgs;

let mypkgs = let
  hasPath = attrset: path: lib.hasAttrByPath (lib.splitString "." path) attrset;
  resolvePath = attrset: path: lib.getAttrFromPath (lib.splitString "." path) attrset;
  resolveDep = path: if isOverlay then (resolvePath outpkgs path) else if (hasPath mypkgs path) then (resolvePath mypkgs path) else (resolvePath pkgs path);

  # TODO: currently nodePackages in nixpkgs uses nodejs-14_x
  nodePackages = pkgs.nodePackages // (callPackage ./node-packages {
    nodejs = pkgs.nodejs-14_x;
  });

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
  crossguid = callPackage ./crossguid {};
  dnsimple-ddns = callPackage ./dnsimple-ddns {};
  fooster-backgrounds = callPackage ./backgrounds {};
  fooster-materia-theme = callPackage ./materia-theme {};
  fpaste = python3Packages.callPackage ./fpaste {};
  ftmp = python3Packages.callPackage ./ftmp {};
  furi = python3Packages.callPackage ./furi {};
  gl3w = callPackage ./gl3w {};
  google-10000-english = callPackage ./google-10000-english {};
  logmail = callPackage ./logmail {};
  mkusb = callPackage ./mkusb {};
  mkwin = callPackage ./mkwin {};
  nix-index-database = callPackage ./nix-index-database {};
  open-stage-control = callPackage ./open-stage-control {
    electron = resolveDep "electron_15";
    nodejs = resolveDep "nodejs-14_x";
  };
  petty = callPackage ./petty {};
  platform-folders = callPackage ./platform-folders {};
  pridecat = callPackage ./pridecat {};
  rofi-pass-wayland = callPackage ./rofi-pass-wayland {
    rofi-wayland = resolveDep "rofi-wayland";
    wtype = resolveDep "wtype";
  };
  sonic-pi-tool = python3Packages.callPackage ./sonic-pi-tool {
    supercollider = resolveDep "supercollider-with-sc3-plugins";
  };
  swaynag-battery = callPackage ./swaynag-battery {};

  mpdris2 = callPackage ./mpdris2 {
    inherit (pkgs) mpdris2;
  };
  sonic-pi = libsForQt5.callPackage ./sonic-pi {
    supercollider = resolveDep "supercollider-with-sc3-plugins";
  };
  sonic-pi-beta = libsForQt5.callPackage ./sonic-pi-beta {
    kissfft = resolveDep "kissfftFloat";
    crossguid = resolveDep "crossguid";
    gl3w = resolveDep "gl3w";
    platform-folders = resolveDep "platform-folders";
    supercollider = resolveDep "supercollider-with-sc3-plugins";
    tailwindcss = resolveDep "tailwindcss";
  };
  supercolliderPlugins = recurseIntoAttrs {
    sc3-plugins = callPackage ./supercollider/plugins/sc3-plugins.nix {
      fftw = resolveDep "fftwSinglePrec";
      supercollider = resolveDep "supercollider";
    };
  };
  supercollider = libsForQt5.callPackage ./supercollider {
    fftw = resolveDep "fftwSinglePrec";
    supercolliderPlugins = resolveDep "supercolliderPlugins";
  };
  supercollider-with-sc3-plugins = (resolveDep "supercollider").override {
    plugins = [ (resolveDep "supercolliderPlugins.sc3-plugins") ];
  };
  tailwindcss = nodePackages.tailwindcss;
  wtype = callPackage ./wtype {
    inherit (pkgs) wtype;
  };

  monofur-nerdfont = nerdfonts.override {
    fonts = [ "Monofur" ];
  };
  kissfftFloat = kissfft.override { datatype = "float"; };

  pass-wayland-otp = (pass-wayland.withExtensions (ext: [ ext.pass-otp ])).overrideAttrs (attrs: {
    meta = with lib; attrs.meta // {
      platforms = platforms.linux;
    };
  });
} // (if isOverlay then {
  inherit nodePackages python3Packages vimPlugins;
} else {
  # TODO: currently nodePackages in nixpkgs uses nodejs-14_x
  nodePackages = dontRecurseIntoAttrs (callPackage ./node-packages {
    nodejs = resolveDep "nodejs-14_x";
  });
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
