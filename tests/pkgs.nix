{ pkgs, ... }:

with pkgs;

lib.listToAttrs (lib.flatten (
  map (drv: if drv ? tests then lib.mapAttrsToList (
      name: value: { name = "pkg-test-" + (if drv ? pname then drv.pname else drv.name) + "-" + name; inherit value; }
    ) drv.tests else [])
    (lib.unique (lib.filter (drv: !drv.meta.unsupported) (lib.collect (drv: lib.isDerivation drv) (
      import ../pkgs {
        inherit pkgs;
        allowUnfree = false;
        isOverlay = false;
      })
    )))
))
