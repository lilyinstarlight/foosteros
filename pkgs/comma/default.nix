{ comma, fetchpatch }:

comma.overrideAttrs (attrs: {
  patches = (attrs.patches or []) ++ [
    # See https://github.com/nix-community/comma/pull/44
    (fetchpatch {
      name = "comma-no-unnecessary-existential-warning.patch";
      url = "https://github.com/nix-community/comma/commit/646e6ed37b64fbc2d3014952645b15d15c9b3aab.patch";
      hash = "sha256-4kdxjvXKosy9eDLPN05MuWU+SDULBq/AxQAr3gH00Xg=";
      postFetch = ''
        sed -i 's/`comma --update`/`--update`/' $out
      '';
    })
  ];
})
