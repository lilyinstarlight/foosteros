{ pkgs, ... }:

with pkgs;

rec {
  fooster-backgrounds = callPackage ./backgrounds {};
  fooster-materia-theme = callPackage ./materia-theme {};
  fpaste = python3Packages.callPackage ./fpaste {};
  ftmp = python3Packages.callPackage ./ftmp {};
  furi = python3Packages.callPackage ./furi {};
  google-10000-english = callPackage ./google-10000-english {};
  open-stage-control = callPackage ./open-stage-control {};
  petty = callPackage ./petty {};
  pridecat = callPackage ./pridecat {};
  rofi-pass-wayland = callPackage ./rofi-pass-wayland { inherit rofi-wayland; };
  rofi-wayland = callPackage ./rofi-wayland {};
  sonic-pi = libsForQt5.callPackage ./sonic-pi {};
  sonic-pi-tool = python3Packages.callPackage ./sonic-pi-tool {};
  swaynag-battery = callPackage ./swaynag-battery {};

  monofur-nerdfont = nerdfonts.override {
    fonts = [ "Monofur" ];
  };

  pass-wayland-otp = pass-wayland.withExtensions (ext: [ ext.pass-otp ]);

  ndi = pkgs.ndi.overrideAttrs (attrs: rec {
    fullVersion = "4.6.2";
    version = builtins.head (builtins.splitVersion fullVersion);

    src = requireFile rec {
      name = "InstallNDISDK_v${version}_Linux.tar.gz";
      sha256 = "181ypfj1bl0kljzrfr6037i14ykg2y4plkzdhym6m3z7kcrnm1fl";
      message = ''
        In order to use NDI SDK version ${fullVersion}, you need to comply with
        NewTek's license and download the appropriate Linux tarball from:

        ${attrs.meta.homepage}

        Once you have downloaded the file, please use the following command and
        re-run the installation:

        \$ nix-prefetch-url file://\$PWD/${name}
      '';
    };

    unpackPhase = ''
      unpackFile ${src}
      echo y | ./InstallNDISDK_v4_Linux.sh
      sourceRoot="NDI SDK for Linux";
    '';
  });

  python3 = let
    self = pkgs.python3.override {
      packageOverrides = (self: super: {
        oscpy = super.pkgs.callPackage ./python-modules/oscpy {};
      });
      inherit self;
    };
  in self;
  python3Packages = python3.pkgs;

  vimPlugins = pkgs.vimPlugins.extend (self: super: callPackage ./vim-plugins {});
}
