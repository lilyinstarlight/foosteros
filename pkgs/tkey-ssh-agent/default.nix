{ lib
, buildGoModule
, fetchFromGitHub
, tkey-device-signer
, nix-update-script
}:

buildGoModule rec {
  pname = "tkey-ssh-agent";
  version = "0.0.6";

  src = fetchFromGitHub {
    owner = "tillitis";
    repo = "tillitis-key1-apps";
    rev = "v${version}";
    hash = "sha256-FqWzeaS6rRrVTw15DsGZDwKfvR8+ljxh4GMl7lzHj58=";
  };

  vendorHash = "sha256-l5IEaaiC19UOsq8IOg7e1m0zzmatijmxTT9s846aNCk=";

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
  };
}
