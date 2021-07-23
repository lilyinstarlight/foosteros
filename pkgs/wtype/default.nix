{ fetchFromGitHub, wtype }:

wtype.overrideAttrs (attrs: rec {
  version = "unstable-2021-07-12";

  src = fetchFromGitHub {
    owner = "atx";
    repo = "wtype";
    #rev = "v${version}";
    rev = "6280f6eb59a7586d6d01b8fa4e4100880c6ae8c6";
    sha256 = "14r24x9qpicqjhfzswyy48y76bxkpl86h7j3fbqsn5lydnws7i90";
  };
})
