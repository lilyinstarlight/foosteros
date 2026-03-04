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
  tkey-totp = callPackage ./tkey-totp {};
  tkey-verification = callPackage ./tkey-verification {};

  # dependents of unfree packages
  crank = callPackage ./crank {};

  # unfree packages
  playdate-sdk = callPackage ./playdate-sdk {};

  # TODO: remove when beets build is fixed
  beets = let
    self = pkgs.python3.override {
      packageOverrides = (self: super: {
        autodocsumm = super.autodocsumm.overridePythonAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
            self.pythonRelaxDepsHook
          ];

          pythonRelaxDeps = (old.pythonRelaxDeps or []) ++ [
            "sphinx"
          ];

          postPatch = (old.postPatch or "") + ''
            substituteInPlace autodocsumm/__init__.py --replace-fail \
              "$(printf 'from sphinx.ext.autodoc import (\n    ClassDocumenter, ModuleDocumenter, ALL, PycodeError,\n    ModuleAnalyzer, AttributeDocumenter, DataDocumenter, Options, ExceptionDocumenter,\n    Documenter, prepare_docstring)')" \
              "$(printf 'from sphinx.errors import PycodeError\nfrom sphinx.pycode import ModuleAnalyzer\nfrom sphinx.util.docstrings import prepare_docstring\nfrom sphinx.ext.autodoc import (\n    ClassDocumenter, ModuleDocumenter, ALL,\n    AttributeDocumenter, DataDocumenter, Options, ExceptionDocumenter,\n    Documenter)')"
          '';
        });
        pyrate-limiter = super.pyrate-limiter_2;
        sphinx-prompt = super.sphinx-prompt.overridePythonAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            # create the old sphinx-prompt directory for compatibility
            # https://github.com/sbrunner/sphinx-prompt/issues/612
            cp -r sphinx{_,-}prompt
          '';
        });
        sphinx-tabs = super.sphinx-tabs.overridePythonAttrs {
          version = "3.4.7-unstable-2026-01-24";
          src = fetchFromGitHub {
            owner = "executablebooks";
            repo = "sphinx-tabs";
            rev = "d613cb7b6bff083227e35e9b3a4c56b24f6c6ad4";
            hash = "sha256-aYlc9bs37Mu4Beuggx0dgVdoRa+X65oDNnYg3Wa4dgc=";
          };
        };
        sphinx-toolbox = super.sphinx-toolbox.overridePythonAttrs (old: {
          dependencies = (old.dependencies or []) ++ [
            self.roman
          ];

          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
            self.pythonRelaxDepsHook
          ];

          pythonRelaxDeps = (old.pythonRelaxDeps or []) ++ [
            "ruamel.yaml"
          ];

          postPatch = (old.postPatch or "") + ''
            substituteInPlace sphinx_toolbox/utils.py --replace-fail \
              'from sphinx.ext.autodoc import Documenter, logger' \
              "$(printf 'import sphinx.util.logging\nlogger = sphinx.util.logging.getLogger(__name__)\nfrom sphinx.ext.autodoc import Documenter')"
          '';
        });
      });
      inherit self;
    };
  in self.pkgs.toPythonApplication self.pkgs.beets;
  # TODO: remove when fixed in nixpkgs
  sonic-pi = pkgs.sonic-pi.override { boost = boost187; ruby = ruby_3_3; };
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
