{ stdenvNoCC, lib, fetchFromGitHub, makeWrapper, iproute2, curl, unstableGitUpdater }:

stdenvNoCC.mkDerivation rec {
  pname = "dnsimple-ddns";
  version = "unstable-2021-12-02";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = pname;
    rev = "d892881ae40d41b439c81f58d86b9a47531c58f7";
    hash = "sha256-GQl3X32sWe9WzQDUjHv8q5eoe49v7m5PZLJffrjUAzA=";
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

  passthru.updateScript = unstableGitUpdater {
    # TODO: remove when NixOS/nixpkgs#160453 is merged
    url = src.gitRepoUrl;
  };

  meta = with lib; {
    description = "DNSimple zone updater for dynamic IPs";
    homepage = "https://github.com/lilyinstarlight/dnsimple-ddns";
    license = licenses.mit;
    maintainers = with maintainers; [ lilyinstarlight ];
    platforms = platforms.linux;
    mainProgram = "ddns";
  };
}
