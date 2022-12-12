{ lib, fetchurl, prusa-slicer, mpfr }:

# TODO: remove after NixOS/nixpkgs#205270 is merged
prusa-slicer.override {
  mpfr = mpfr.overrideAttrs (attrs: {
    patches = (attrs.patches or []) ++ [
      (fetchurl { # https://gitlab.inria.fr/mpfr/mpfr/-/issues/1
        url = "https://www.mpfr.org/mpfr-4.1.1/patch01";
        hash = "sha256-gKPCcJviGsqsEqnMmYiNY6APp3+3VXbyBf6LoZhP9Eo=";
      })
    ];
  });
}
