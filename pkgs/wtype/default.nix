{ fetchFromGitHub, wtype }:

wtype.overrideAttrs (attrs: rec {
  version = "unstable-2021-09-22";

  src = fetchFromGitHub {
    owner = "atx";
    repo = "wtype";
    #rev = "v${version}";
    rev = "707c5febee1cf6ec681d62800cbacbf1dd7a09e5";
    sha256 = "sha256-Pj/6RGT/Bxu6WAZZpn2lpb3qYmvnZqPiQ8Z/d4Kd4AM=";
  };
})
