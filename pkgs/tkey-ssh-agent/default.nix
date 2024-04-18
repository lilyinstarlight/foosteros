{ lib
, buildGoModule
, fetchFromGitHub
, tkey-device-signer
, nix-update-script
}:

buildGoModule rec {
  pname = "tkey-ssh-agent";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "tillitis";
    repo = "tillitis-key1-apps";
    rev = "v${version}";
    hash = "sha256-Uf3VJJfZn4UYX1q79JdaOfrore+L/Mic3whzpP32JV0=";
  };

  vendorHash = "sha256-SFyp1UB6+m7/YllRyY56SwweJ3X175bChXQYiG2M7zM=";

  subPackages = [ "cmd/tkey-ssh-agent" ];

  ldflags = [
    "-X main.version=${version}"
  ];

  preConfigure = ''
    cp ${tkey-device-signer}/app.bin cmd/tkey-ssh-agent/app.bin
  '';

  passthru.updateScript = nix-update-script {};

  meta = with lib; {
    description = "An OpenSSH-compatible agent for use with the Tillitis TKey USB security token";
    homepage = "https://github.com/tillitis/tillitis-key1-apps";
    license = licenses.gpl2Only;
    platforms = platforms.all;
    maintainers = with maintainers; [ lilyinstarlight ];
    mainProgram = "tkey-ssh-agent";
  };
}
