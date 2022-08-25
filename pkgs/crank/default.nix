{ lib, stdenv, rustPlatform, fetchFromGitHub, makeWrapper, rustNightlyToolchain, gcc-arm-embedded, playdate-sdk, xdg-utils }:

rustPlatform.buildRustPackage rec {
  pname = "crank";
  version = "unstable-2022-04-25";

  src = fetchFromGitHub {
    owner = "pd-rs";
    repo = pname;
    rev = "50b3ba869cdfe8c2830311616304a49b5f8d1db9";
    hash = "sha256-lkbF01bibEgJ45r7JanVKRyTybF0xsHMFadiErIk2+Y=";
  };

  cargoPatches = [
    ./crank-fix-no-rustup.patch
    ./crank-fix-lock.patch
  ];

  cargoHash = "sha256-rZF8dpq8i2YMnVqZFUOQBOQbqYWVOMCgZjIixEZHlwQ=";

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    wrapProgram $out/bin/crank \
      --prefix PATH : '${lib.makeBinPath [ rustNightlyToolchain gcc-arm-embedded playdate-sdk xdg-utils ]}' \
      --set PLAYDATE_SDK_PATH '${playdate-sdk}/sdk'
  '';

  meta = with lib; {
    description = "A cargo wrapper for creating games for the Playdate handheld gaming system";
    license = licenses.mit;
    homepage = "https://github.com/rtsuk/crank";
    maintainers = with maintainers; [ lilyinstarlight ];
    platforms = platforms.linux;
    dependsUnfree = true;
  };
}
