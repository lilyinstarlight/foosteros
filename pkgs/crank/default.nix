{ lib, stdenv, rustPlatform, fetchFromGitHub, makeWrapper, rustNightlyToolchain, gcc-arm-embedded, playdate-sdk, xdg-utils }:

rustPlatform.buildRustPackage rec {
  pname = "crank";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "pd-rs";
    repo = pname;
    rev = version;
    hash = "sha256-CD2x4Y4/9q/RtqHRWxID5+jBlZdnAkqxfNMcQpEMAyo=";
  };

  cargoPatches = [
    ./crank-linux-support.patch
    ./crank-pdxinfo.patch
    ./crank-fix-build-std.patch
    ./crank-fix-lock.patch
  ];

  cargoHash = "sha256-HmZCtj+QQS7fUoQQoBzMNIfVwmSaWNbWccg2/gEuR+c=";

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
  };
}
