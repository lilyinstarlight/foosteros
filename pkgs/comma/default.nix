{ comma }:

comma.overrideAttrs (attrs: {
  patches = (attrs.patches or []) ++ [
    ./comma-no-useless-existential-warning.patch
  ];
})
