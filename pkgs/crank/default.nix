{ lib, stdenv, rustPlatform, fetchFromGitHub, makeWrapper, rustNightlyToolchain, cargo-xbuild, gcc-arm-embedded, playdate-sdk, xdg-utils }:

rustPlatform.buildRustPackage rec {
  pname = "crank";
  version = "unstable-2022-03-03";

  src = fetchFromGitHub {
    owner = "rtsuk";
    repo = pname;
    rev = "2ce9289a4c112fd1468d34f3442c746602b141f9";
    hash = "sha256-xZsff9tl0q2T9ppn/i891g8K+kfFNRQQqspWz0ZqGOw=";
  };

  cargoPatches = [
    ./crank-linux-support.patch
    ./crank-pdxinfo.patch
  ];

  cargoHash = "sha256-kCH9+ea+I+n8w6A0peyIRATZb0Ss+YZmF+SPvKXDem4=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/crank \
      --prefix PATH : '${lib.makeBinPath [ rustNightlyToolchain cargo-xbuild gcc-arm-embedded playdate-sdk xdg-utils ]}' \
      --set PLAYDATE_SDK_PATH '${playdate-sdk}/sdk'
  '';

  meta = with lib; {
    description = "A cargo wrapper for creating games for the Playdate handheld gaming system";
    license = licenses.mit;
    homepage = "https://github.com/rtsuk/crank";
    platforms = platforms.linux;
  };
}
