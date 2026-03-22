{ lib
, stdenv
, buildGoModule
, fetchFromGitHub
, udev
, makeBinaryWrapper
, podman
, socat
, nix-update-script
}:

stdenv.mkDerivation (finalAttrs: let
  mkCmd = name: args: buildGoModule (args // {
    pname = "${finalAttrs.pname}-${name}";

    inherit (finalAttrs) version src;

    modRoot = "cmd/${name}";

    ldflags = (args.ldflags or []) ++ [
      "-X main.version=${finalAttrs.version}"
    ];

    meta = finalAttrs.meta // {
      mainProgram = name;
    };
  });
in rec {
  pname = "tkey-devtools";
  version = "0.0.2";

  src = fetchFromGitHub {
    owner = "tillitis";
    repo = "tkey-devtools";
    rev = "v${version}";
    hash = "sha256-hKdH+UQsonXG6Iet3vYaKWzSWOs4o1j1zMcmmG964yA=";
  };

  passthru.cmdList = {
    tkey-runapp = {
      vendorHash = "sha256-kJkUe2wxRtRgH2Ib4v6xYGTZC8KDINOgfaf3Uvw5+1s=";
    };
    hidread = {
      buildInputs = [ udev ];

      vendorHash = "sha256-DxCxv56D0bGQBZEvmRtoUP+C0rPRN6DLun1nyYfOFhU=";
    };
  };

  nativeBuildInputs = [ makeBinaryWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    for cmd in ${lib.escapeShellArgs (lib.mapAttrsToList (name: args: lib.getExe (mkCmd name args)) finalAttrs.passthru.cmdList)}; do
      ln -s "$cmd" $out/bin/
    done

    install -Dm755 run-tkey-qemu $out/bin/run-tkey-qemu

    mkdir -p $out/lib/udev/rules.d
    install -Dm644 system/60-tkey.rules $out/lib/udev/rules.d/60-tkey.rules

    wrapProgram $out/bin/run-tkey-qemu \
      --prefix PATH : ${lib.makeBinPath [ podman socat ]}

    runHook postInstall
  '';

  # TODO: test if this still works?
  #passthru.updateScript = nix-update-script {};

  meta = with lib; {
    description = "Development tools for the Tillitis TKey USB security token";
    homepage = "https://github.com/tillitis/tkey-devtools";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ /*lilyinstarlight*/ ];
    mainProgram = "tkey-runapp";
  };
})
