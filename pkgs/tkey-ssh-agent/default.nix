{ lib
, buildGoModule
, fetchFromGitHub
, tkey-device-signer
, nix-update-script
}:

buildGoModule rec {
  pname = "tkey-ssh-agent";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "tillitis";
    repo = "tillitis-key1-apps";
    rev = "v${version}";
    hash = "sha256-ndS9eNxhZTCxaxEF/J3FzIA8xtlVdbm9q9W1I9lC8+k=";
  };

  vendorHash = "sha256-+JTGgiCLvJsju3gbqbid6TZCfSgjPySfeaEtiyuTlWM=";

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
    maintainers = with maintainers; [ /*lilyinstarlight*/ ];
    mainProgram = "tkey-ssh-agent";
  };
}
