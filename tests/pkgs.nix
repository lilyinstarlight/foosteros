{ pkgs, self, ... }:

with pkgs;

lib.listToAttrs (lib.flatten (
  map (drv: [ { name = "pkg-" + (if drv ? pname then drv.pname else drv.name); value = drv; } ] ++
    lib.optionals (drv ? tests) (lib.mapAttrsToList (name: value: { name = "pkg-" + (if drv ? pname then drv.pname else drv.name) + "-test-" + name; inherit value; }) drv.tests))
  (lib.unique (lib.filter (drv: !drv.meta.unsupported && !drv.meta.broken && !drv.meta.unfree && (drv.meta ? dependsUnfree -> !drv.meta.dependsUnfree)) (lib.collect
    (drv: lib.isDerivation drv)
    self.legacyPackages.${pkgs.stdenv.buildPlatform.system}
  )))
))
