{ lib, stdenv, rustPlatform, fetchFromGitHub, makeWrapper, rustNightlyToolchain, gcc-arm-embedded, playdate-sdk, xdg-utils }:

rustPlatform.buildRustPackage rec {
  pname = "crank";
  version = "unstable-2022-03-18";

  src = fetchFromGitHub {
    owner = "pd-rs";
    repo = pname;
    rev = "81b532c0160d2a1ea93461d421f53de113c12ee9";
    hash = "sha256-k41Hz2T32vyTzCIIqoxsGTxELgAhwkhtK89uo4w4WZ8=";
  };

  cargoPatches = [
    ./crank-linux-support.patch
    ./crank-pdxinfo.patch
    ./crank-fix-lock.patch
    ./crank-fix-build-std.patch
  ];

  cargoHash = "sha256-6Dq3tbEbxDyYh4M0WBUCISndftfjYp1V07SQJwdXEZ0=";

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
    platforms = platforms.linux;
  };
}
