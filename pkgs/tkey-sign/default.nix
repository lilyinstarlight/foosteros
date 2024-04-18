{ lib
, buildGoModule
, fetchFromGitHub
, tkey-device-signer
, nix-update-script
}:

buildGoModule rec {
  pname = "tkey-sign";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "tillitis";
    repo = "tkey-sign-cli";
    rev = "v${version}";
    hash = "sha256-glBmC3VBHggSLP3RY1TxTvrsVy0ilA+6ML13tvfXx04=";
  };

  vendorHash = "sha256-e7/XbLBZw9f/ANuXgHcKE8EYlAmcrWmyqUyM+NoCdow=";

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
    mainProgram = "tkey-sign";
  };
}
