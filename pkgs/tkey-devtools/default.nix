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

stdenv.mkDerivation (finalAttrs: rec {
  pname = "tkey-devtools";
  version = "0.0.3";

  src = fetchFromGitHub {
    owner = "tillitis";
    repo = "tkey-devtools";
    rev = "v${version}";
    hash = "sha256-FZXTL1kTdfngHuRC2mVwIpU7W1hHDDbKe1THVHYNSP8=";
  };

  passthru = let
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
  in {
    cmdList = {
      tkey-runapp = {
        vendorHash = "sha256-eOOgSwX1FF+8tkeSOmvXbztOFsUa3sL4XuRpMMD/Grc=";
      };
      hidread = {
        buildInputs = [ udev ];

        vendorHash = "sha256-DxCxv56D0bGQBZEvmRtoUP+C0rPRN6DLun1nyYfOFhU=";
      };
    };

    cmds = lib.mapAttrs (name: args: mkCmd name args) finalAttrs.passthru.cmdList;

    # TODO: test if this still works?
    updateScript = nix-update-script {
      extraArgs = lib.concatMap (name: [ "-s" ("cmds." + name) ]) (lib.attrNames finalAttrs.passthru.cmds);
    };
  };

  nativeBuildInputs = [ makeBinaryWrapper ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    for cmd in ${lib.escapeShellArgs (lib.mapAttrsToList (_name: cmd: lib.getExe cmd) finalAttrs.passthru.cmds)}; do
      ln -s "$cmd" $out/bin/
    done

    install -Dm755 run-tkey-qemu $out/bin/run-tkey-qemu

    mkdir -p $out/lib/udev/rules.d
    install -Dm644 system/60-tkey.rules $out/lib/udev/rules.d/60-tkey.rules

    wrapProgram $out/bin/run-tkey-qemu \
      --prefix PATH : ${lib.makeBinPath [ podman socat ]}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Development tools for the Tillitis TKey USB security token";
    homepage = "https://github.com/tillitis/tkey-devtools";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ /*lilyinstarlight*/ ];
    mainProgram = "tkey-runapp";
  };
})
