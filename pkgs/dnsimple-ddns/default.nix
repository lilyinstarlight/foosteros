{ stdenvNoCC, lib, fetchFromGitHub, makeWrapper, iproute2, curl, unstableGitUpdater }:

stdenvNoCC.mkDerivation rec {
  pname = "dnsimple-ddns";
  version = "unstable-2020-04-16";

  src = fetchFromGitHub {
    owner = "lilyinstarlight";
    repo = pname;
    rev = "7ea80486077d0f2436ab6031a17eddcb8259af50";
    hash = "sha256-oMGABa58MijGcVW4UF/kMetC5yVyQv1kmJSai4f8r00=";
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
