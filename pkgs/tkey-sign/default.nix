{ lib
, buildGoModule
, fetchFromGitHub
, tkey-device-signer
, nix-update-script
}:

buildGoModule rec {
  pname = "tkey-sign";
  version = "0.0.8";

  src = fetchFromGitHub {
    owner = "tillitis";
    repo = "tkey-sign-cli";
    rev = "v${version}";
    hash = "sha256-NYb2PMqjY0g62qThKvkFqkfS2lIupwYq+XMVgkI6V74=";
  };

  vendorHash = "sha256-FcifwAQ81rin2Z2RUesFVt6b4KtePzrPKb2dsZ+eiRg=";

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
    maintainers = with maintainers; [ lilyinstarlight ];
  };
}
