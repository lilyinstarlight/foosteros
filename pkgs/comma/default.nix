{ lib, fetchpatch, comma }:

comma.overrideAttrs (attrs: {
  patches = (attrs.patches or []) ++ [
    # See nix-community/comma#34
    (fetchpatch {
      name = "add-db-writeability-check.patch";
      url = "https://github.com/nix-community/comma/commit/55dd39871dde030c3efaa87c2b3b1b104a2be097.patch";
      hash = "sha256-JdL1/w4QFEAJJ7e81OqZZazP7Vcp7Bwewx3o3FFQabg=";
    })
  ];

  # TODO: Remove when nix-community/comma#35 is merged
  passthru = (attrs.passthru or {}) // {
    tests = lib.optionalAttrs (attrs ? passthru && attrs.passthru ? tests) (removeAttrs attrs.passthru.tests [ "version" ]);
  };
})
