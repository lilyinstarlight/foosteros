{ lib
, stdenvNoCC
, fetchFromGitHub
, makeWrapper
, iproute2
, curl
, unstableGitUpdater
}:

stdenvNoCC.mkDerivation {
  pname = "dnsimple-ddns";
  version = "unstable-2024-03-11";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = "dnsimple-ddns";
    rev = "f4a141def6c6631df237356beabfc2582146a40d";
    hash = "sha256-wnzTWlYQpXKNqw2oCUtlt1MF1fvcV2zONdBnbnxD+MA=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  dontConfigure = true;
  dontBuild = true;

  postPatch = ''
    patchShebangs .
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ddns $out/bin/ddns

    wrapProgram $out/bin/ddns \
      --prefix PATH : "${lib.makeBinPath [ iproute2 curl ]}"
  '';

  passthru.updateScript = unstableGitUpdater {};

  meta = with lib; {
    description = "DNSimple zone updater for dynamic IPs";
    homepage = "https://github.com/lilyinstarlight/dnsimple-ddns";
    license = licenses.mit;
    maintainers = with maintainers; [ lilyinstarlight ];
    platforms = platforms.linux;
    mainProgram = "ddns";
  };
}
