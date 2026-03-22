{ lib
, buildGoModule
, fetchFromGitHub
, tkey-device-signer
, nix-update-script
}:

buildGoModule rec {
  pname = "tkey-sign";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "tillitis";
    repo = "tkey-sign-cli";
    rev = "v${version}";
    hash = "sha256-a3ljf30bYozfcM5OxehXSilQytElqnkNo44mrvRu6Ok=";
  };

  vendorHash = "sha256-/UCSneF6WPy0Hby1HBDJFCNJjA0DOBsil0VkqevdtOg=";

  subPackages = [ "cmd/tkey-sign" ];

  ldflags = [
    "-X main.version=${version}"
  ];

  preConfigure = ''
    cp ${tkey-device-signer}/app.bin cmd/tkey-sign/app.bin
  '';

  passthru.updateScript = nix-update-script {};

  meta = with lib; {
    description = "CLI to sign messages with the Tillitis TKey USB security token";
    homepage = "https://github.com/tillitis/tkey-sign-cli";
    license = licenses.gpl2Only;
    platforms = platforms.all;
    maintainers = with maintainers; [ /*lilyinstarlight*/ ];
    mainProgram = "tkey-sign";
  };
}
