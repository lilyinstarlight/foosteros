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

  # TODO: remove when fixed in nixpkgs
  sonic-pi = (pkgs.sonic-pi.override { boost = boost187; ruby = ruby_3_3; }).overrideAttrs (attrs: { meta = (attrs.meta or {}) // { broken = false; }; });

  # TODO: remove when NixOS/nixpkgs#535887 is fixed
  cantarell-fonts = pkgs.cantarell-fonts.override {
    python3 = let
      self = pkgs.python3.override {
        packageOverrides = (self: super: {
          afdko = super.afdko.overridePythonAttrs rec {
            version = "4.0.2";
            src = super.afdko.src.override {
              tag = version;
              hash = "sha256-lXFNmUESfobN59I4H4/P8NWqcytucf1Sf9DF5tdupSQ=";
            };
            patches = [
              (fetchpatch {
                url = "https://github.com/NixOS/nixpkgs/raw/a95fcb976497422a1df26883b7d3907470c55543/pkgs/development/python-modules/afdko/no-pypi-build-tools.patch";
                hash = "sha256-c5VMdpjDgFfJb5sLQu+gWDjCUQ50Cjt0+mOvtRf5FSA=";
              })
              (fetchpatch {
                url = "https://github.com/NixOS/nixpkgs/raw/a95fcb976497422a1df26883b7d3907470c55543/pkgs/development/python-modules/afdko/use-dynamic-system-antlr4-runtime.patch";
                hash = "sha256-3qN9Z1sfGliBBr0jMaJ/tfsT0QD6XRv+UoXLPy8KdCY=";
              })
              (fetchpatch {
                url = "https://github.com/adobe-type-tools/afdko/commit/3b78bea15245e2bd2417c25ba5c2b8b15b07793c.patch";
                excludes = [
                  "CMakeLists.txt"
                  "requirements.txt"
                ];
                hash = "sha256-Ao5AUVm1h4a3qidqlBFWdC7jiXyBfXQEnsT7XsXXXRU=";
              })
            ];
            build-system = (super.afdko.build-system or []) ++ [
              self.scikit-build
            ];
            env = (super.afdko.env or {}) // lib.optionalAttrs super.afdko.stdenv.cc.isClang {
              NIX_CFLAGS_COMPILE = toString [
                "-Wno-error=incompatible-function-pointer-types"
                "-Wno-error=int-conversion"
              ];
            };
            disabledTests = [
              "test_glyphs_2_7"
              "test_hinting_data"
              "test_waterfallplot"
              "test_type1_supported_hint"
            ] ++ lib.optionals (super.afdko.stdenv.cc.isGNU) [
              "test_dump"
              "test_input_formats"
              "test_other_input_formats"
            ] ++ (super.afdko.disabledTests or []);
            postInstall = (super.afdko.postInstall or "") + ''
              rm -r $out/{_skbuild,c,tests}
            '';
            preCheck = (super.afdko.preCheck or "") + ''
              rm -r _skbuild
            '';
          };
          booleanoperations = super.booleanoperations.overridePythonAttrs rec {
            version = "0.9.0";
            src = super.booleanoperations.src.override {
              tag = version;
              hash = "sha256-W/Un8oLnoHnlox6qZXtJQTAMMepNI5vy4s0G7Kt6Dio=";
            };
            disabledTests = [
              "test_QTail_reversed_difference"
              "test_QTail_reversed_intersection"
              "test_QTail_reversed_union"
              "test_QTail_reversed_xor"
              "test_Q_difference"
              "test_Q_intersection"
              "test_Q_union"
              "test_Q_xor"
            ];
          };
          fontparts = super.fontparts.overridePythonAttrs rec {
            version = "0.13.1";
            src = super.fontparts.src.override {
              tag = version;
              hash = "sha256-/RHxRdwuwQXFteDVzoxLjYtPnsTUJOU9JS77IP4U+sQ=";
            };
            postPatch = lib.replaceString "substituteInPlace pyproject.toml \\\n  --replace-fail ', \"vcs-versioning\"' \"\"" "" super.fontparts.postPatch;
          };
          fontpens = super.fontpens.overridePythonAttrs rec {
            version = "0.3.0";
            src = super.fontpens.src.override {
              tag = "v${version}";
              hash = "sha256-IXxf5ZHAfgaNFgdpUNNdJixJiSNcNLs+nYW8ejSQuo4=";
            };
          };
        });
        inherit self;
      };
    in self;
  };
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
