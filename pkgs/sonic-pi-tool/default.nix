{ lib
, stdenv
, fetchFromGitHub
, makePythonPath
, makeWrapper
, python
, click
, oscpy
, psutil
, sonic-pi
, ruby
, erlang
, supercollider-with-sc3-plugins
, jack2
, unstableGitUpdater
}:

let
  pythonPath = makePythonPath [
    # sonic-pi-tool runtime deps
    click
    oscpy
    psutil
  ];

  binPath = lib.makeBinPath [
    # sonic-pi runtime deps
    ruby
    erlang
    supercollider-with-sc3-plugins
    jack2
  ];
in

stdenv.mkDerivation {
  pname = "sonic-pi-tool";
  version = "0-unstable-2021-03-07";

  src = fetchFromGitHub {
    owner = "emlyn";
    repo = "sonic-pi-tool";
    #rev = "v${version}";
    rev = "b955369294b7669b2706b26d388ec2c2a9d0d3a2";
    hash = "sha256-HgJSZGjm0Uwu2TTgv/FMTRKLUdT8ILNaiL4wKJ1RyBs=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    python
  ];

  dontConfigure = true;
  dontBuild = true;
  doInstallCheck = true;

  installPhase = ''
    mkdir -p $out/bin
    cp sonic-pi-tool.py $out/bin/sonic-pi-tool
    chmod +x $out/bin/sonic-pi-tool

    substituteInPlace $out/bin/sonic-pi-tool \
      --replace \
        'default_paths = (' \
        'default_paths = ('"'"'${sonic-pi}/app'"'"', '

    patchShebangs $out/bin

    wrapProgram $out/bin/sonic-pi-tool \
      --prefix PYTHONPATH : ${pythonPath} \
      --prefix PATH : ${binPath}
  '';

  installCheckPhase = "$out/bin/sonic-pi-tool --help";

  passthru.updateScript = unstableGitUpdater {};

  meta = with lib; {
    description = "Tool for interfacing with the Sonic Pi server from the command line";
    homepage = "https://github.com/emlyn/sonic-pi-tool";
    license = licenses.mpl20;
    maintainers = with maintainers; [ /*lilyinstarlight*/ ];
    platforms = [ "x86_64-linux" "i686-linux" "aarch64-linux" "armv7l-linux" ];
    mainProgram = "sonic-pi-tool";
  };
}
