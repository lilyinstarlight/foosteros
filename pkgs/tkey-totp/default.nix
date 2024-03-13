{ lib
, buildGoModule
, tkeyStdenv
, fetchFromGitHub
, tkey-libs
, nix-update-script
}:

buildGoModule rec {
  pname = "tkey-totp";
  version = "unstable-2024-01-05";

  src = fetchFromGitHub {
    owner = "tillitis";
    repo = "tkey-totp";
    rev = "72b19564eda32ffa4fc699fdbbf0d2309bdb604f";
    hash = "sha256-zsjOEhLmSVlPFjmPUaPFRXrf24h9eWcGPqhE0hVWsgw=";
  };

  vendorHash = "sha256-SUoH/s35SbKVWAZrTQrOqqHzL5oNPEt1llK+iVGbRos=";

  subPackages = [ "cmd/tkey-totp" ];

  ldflags = [
    "-X main.version=${version}"
  ];

  app = tkeyStdenv.mkDerivation {
    pname = "${pname}-app";

    inherit src version;

    makeFlags = [
      "LIBDIR=${tkey-libs}"
      "app/app.bin"
    ];

    installPhase = ''
      runHook preInstall

      mkdir $out
      cp -T app/app.bin $out/app.bin

      runHook postInstall
    '';
  };

  preConfigure = ''
    cp $app/app.bin cmd/tkey-totp/app.bin
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = with lib; {
    description = "TOTP key app for use with the Tillitis TKey";
    homepage = "https://github.com/tillitis/tkey-totp";
    license = licenses.gpl2Only;
    platforms = platforms.all;
    maintainers = with maintainers; [ lilyinstarlight ];
    mainProgram = "tkey-totp";
  };
}
