{ lib
, buildGoModule
, fetchFromGitHub
, tkey-device-signer
, nix-update-script
}:

buildGoModule rec {
  pname = "tkey-sign";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "tillitis";
    repo = "tkey-sign-cli";
    rev = "v${version}";
    hash = "sha256-QsfV8jql6apPWfAfY+AqUPr6UJmE/FDOC/Nto4XqFEs=";
  };

  vendorHash = "sha256-jtVCy3QLqXeZ/LWLmP36qeUhX5fBp8B1tLPmEOWafV0=";

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
