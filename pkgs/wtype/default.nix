{ fetchFromGitHub, wtype }:

wtype.overrideAttrs (attrs: rec {
  version = "unstable-2021-08-17";

  src = fetchFromGitHub {
    owner = "atx";
    repo = "wtype";
    #rev = "v${version}";
    rev = "6536edfb917ed008c99b6cdd8d78c911782cb8e1";
    sha256 = "10pshf98x0ljs20h911vyjwrr06sgqcrcshhx59crf68sxdr0fry";
  };
})
