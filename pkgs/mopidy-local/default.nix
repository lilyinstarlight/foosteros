{ lib, mopidy-local, fetchpatch }:

mopidy-local.overrideAttrs (attrs: {
  patches = (attrs.patches or []) ++ [
    # Fix tests with newer Mopidy versions >=3.4.0
    (fetchpatch {
      name = "update-tests-for-mopidy-3.4.0.patch";
      url = "https://github.com/mopidy/mopidy-local/commit/f2c198f8eb253f62100afc58f652e73a76d5a090.patch";
      hash = "sha256-jrlZc/pd00S5q9nOfV1OXu+uP/SvH+Xbi7U52aZajj4=";
    })
  ];

  meta = with lib; (attrs.meta or {}) // {
    platforms = platforms.linux;
  };
})
