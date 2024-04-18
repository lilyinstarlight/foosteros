{ lib
, buildGoModule
, tkeyStdenv
, fetchFromGitHub
, tkey-libs
, nix-update-script
}:

buildGoModule rec {
  pname = "tkey-random-generator";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "tillitis";
    repo = "tkey-random-generator";
    rev = "v${version}";
    hash = "sha256-aJF3Z/fbh7kbWlU/vd35E0wlvvoi+ySNydDovFZDxqM=";
  };

  vendorHash = "sha256-m5n9i8Znx4lVL2pVIJeUKfY98S1MMQ6DWwI/rbCtlAw=";

  subPackages = [ "cmd/tkey-random-generator" ];

  ldflags = [
    "-X main.version=${version}"
  ];

  app = tkeyStdenv.mkDerivation {
    pname = "${pname}-app";

    inherit src version;

    patches = [
      ./tkey-libs-0-1-1.patch
    ];

    makeFlags = [
      "LIBDIR=${tkey-libs}"
      "random-generator/app.bin"
    ];

    installPhase = ''
      runHook preInstall

      mkdir $out
      cp -T random-generator/app.bin $out/app.bin

      runHook postInstall
    '';
  };

  preConfigure = ''
    cp $app/app.bin cmd/tkey-random-generator/app.bin
  '';

  passthru.updateScript = nix-update-script {};

  meta = with lib; {
    description = "Random data generator for use with the Tillitis TKey with output signing";
    homepage = "https://github.com/tillitis/tkey-random-generator";
    license = licenses.gpl2Only;
    platforms = platforms.all;
    maintainers = with maintainers; [ lilyinstarlight ];
    mainProgram = "tkey-random-generator";
  };
}
