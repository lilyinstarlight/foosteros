{ lib
, buildGoModule
, fetchFromGitHub
, makeBinaryWrapper
, podman
, socat
, nix-update-script
}:

buildGoModule rec {
  pname = "tkey-devtools";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "tillitis";
    repo = "tkey-devtools";
    rev = "v${version}";
    hash = "sha256-ClWL4aNu9qcwENK4NmlsnjAYAKQE+Hq57gN++nOJTRE=";
  };

  vendorHash = "sha256-c53xOeQTpo/J2k+kEYei0q3QaD4rqB+9EZR+s0yNLik=";

  nativeBuildInputs = [ makeBinaryWrapper ];

  subPackages = [ "cmd/tkey-runapp" ];

  ldflags = [
    "-X main.version=${version}"
  ];

  postInstall = ''
    install -Dm755 run-tkey-qemu $out/bin/run-tkey-qemu

    mkdir -p $out/lib/udev/rules.d
    install -Dm644 system/60-tkey.rules $out/lib/udev/rules.d/60-tkey.rules

    wrapProgram $out/bin/run-tkey-qemu \
      --prefix PATH : ${lib.makeBinPath [ podman socat ]}
  '';

  passthru.updateScript = nix-update-script {};

  meta = with lib; {
    description = "Development tools for the Tillitis TKey USB security token";
    homepage = "https://github.com/tillitis/tkey-devtools";
    license = licenses.gpl2Only;
    platforms = platforms.all;
    maintainers = with maintainers; [ lilyinstarlight ];
    mainProgram = "tkey-runapp";
  };
}
