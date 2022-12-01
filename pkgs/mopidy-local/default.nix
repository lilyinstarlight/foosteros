{ lib, mopidy-local }:

mopidy-local.overrideAttrs (attrs: {
  patches = (attrs.patches or []) ++ [
    ./mopidy-tests-3.4.0.patch
  ];
})
