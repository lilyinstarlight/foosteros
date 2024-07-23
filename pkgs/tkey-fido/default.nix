{ lib
, buildGoModule
, tkeyStdenv
, fetchFromGitHub
, fetchpatch
, tkey-libs
, nix-update-script
}:

buildGoModule rec {
  pname = "tkey-fido";
  version = "0-unstable-2023-10-16";

  src = fetchFromGitHub {
    owner = "tillitis";
    repo = "tkey-fido";
    rev = "7bfbc40c3a9cd19191adc34e87b183ac702527e6";
    hash = "sha256-Ho1T7YwCoAxQhl2oQGlG7Sj1jfl4l+eMccGuS6sF6fc=";
  };

  vendorHash = "sha256-2JeIHnbW8qa3yR9PJ2FaihVY8r4yS/izEMqW0hEyvwk=";

  subPackages = [ "cmd/tkey-fido" ];

  ldflags = [
    "-X main.version=${version}"
  ];

  app = tkeyStdenv.mkDerivation {
    pname = "${pname}-app";

    inherit src version;

    patches = [
      (fetchpatch {
        name = "authenticate-state-machine.patch";
        url = "https://github.com/tillitis/tkey-fido/commit/28be5f89fb6704719c0bf974bd4b04ed3a5336bb.diff";
        hash = "sha256-f24yG17R8XRoku6lVOj6eXjuowzfVlmE2wCbwxTFcO8=";
      })
      ./tkey-libs-0-1-1.patch
    ];

    makeFlags = [
      "LIBDIR=${tkey-libs}"
      "device-fido/app.bin"
    ];

    installPhase = ''
      runHook preInstall

      mkdir $out
      cp -T device-fido/app.bin $out/app.bin

      runHook postInstall
    '';
  };

  preConfigure = ''
    cp $app/app.bin cmd/tkey-fido/app.bin
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = with lib; {
    description = "U2F/FIDO implementation for Tillitis TKey";
    homepage = "https://github.com/tillitis/tkey-fido";
    license = licenses.gpl2Only;
    platforms = platforms.all;
    maintainers = with maintainers; [ /*lilyinstarlight*/ ];
    mainProgram = "tkey-fido";
  };
}
