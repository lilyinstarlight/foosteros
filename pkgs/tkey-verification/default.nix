{ lib
, buildGoModule
, fetchFromGitHub
, nix-update-script
}:

buildGoModule rec {
  pname = "tkey-verification";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "tillitis";
    repo = "tkey-verification";
    rev = "v${version}";
    hash = "sha256-WoV0AsMWMupRW+rJpsD28zGdASzeqQmIu9OGvFNcSW4=";
  };

  vendorHash = "sha256-ikCn68wh+46KCEAHjlt7ATrIcPyIpL/WwR0b0rfdWfY=";

  subPackages = [ "cmd/tkey-verification" ];

  passthru.updateScript = nix-update-script {};

  meta = with lib; {
    description = "A tool used for signing a TKey identity and verifying that it still has the same identity as it did when it was produced by Tillitis";
    homepage = "https://github.com/tillitis/tkey-verification";
    license = licenses.gpl2Only;
    platforms = platforms.all;
    maintainers = with maintainers; [ /*lilyinstarlight*/ ];
    sourceProvenance = with sourceTypes; [ fromSource binaryFirmware ];
    mainProgram = "tkey-verification";
  };
}
