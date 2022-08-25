{ pkgs, self, ... }:

with pkgs;

lib.listToAttrs (lib.flatten (
  map (drv: if drv ? tests
    then lib.mapAttrsToList (name: value: { name = "pkg-test-" + (if drv ? pname then drv.pname else drv.name) + "-" + name; inherit value; }) drv.tests
    else []
  )
    (lib.unique (lib.filter (drv: !drv.meta.unsupported && !drv.meta.unfree && (drv.meta ? dependsUnfree -> !drv.meta.dependsUnfree)) (lib.collect
      (drv: lib.isDerivation drv)
      self.legacyPackages.${pkgs.stdenv.hostPlatform.system}
    )))
))
