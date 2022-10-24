{ lib, stdenv, rustPlatform, fetchFromGitHub, makeWrapper, rustNightlyToolchain, gcc-arm-embedded, playdate-sdk, xdg-utils, unstableGitUpdater }:

rustPlatform.buildRustPackage rec {
  pname = "crank";
  version = "unstable-2022-05-16";

  src = fetchFromGitHub {
    owner = "pd-rs";
    repo = pname;
    rev = "b438812657ef4b07368be7ea9dfc1909d793385f";
    hash = "sha256-ocNnHri+jEhy5uNQZI6R21fsmVx2TbtsnKpg53BtMj0=";
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

  passthru.updateScript = unstableGitUpdater {};

  meta = with lib; {
    description = "A cargo wrapper for creating games for the Playdate handheld gaming system";
    license = licenses.mit;
    homepage = "https://github.com/rtsuk/crank";
    maintainers = with maintainers; [ lilyinstarlight ];
    platforms = platforms.linux;
    dependsUnfree = true;
  };
}
