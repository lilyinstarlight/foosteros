{ lib, buildPythonApplication, fetchFromGitHub, click, oscpy, psutil, sonic-pi, ruby, erlang, bash, supercollider-with-sc3-plugins, jack2, runCommand }:

let sonic-pi-tool =
buildPythonApplication rec {
  pname = "sonic-pi-tool";
  version = "unstable-2021-03-07";

  src = fetchFromGitHub {
    owner = "emlyn";
    repo = pname;
    #rev = "v${version}";
    rev = "b955369294b7669b2706b26d388ec2c2a9d0d3a2";
    hash = "sha256-HgJSZGjm0Uwu2TTgv/FMTRKLUdT8ILNaiL4wKJ1RyBs=";
  };

  pythonPath = [
    # sonic-pi-tool runtime deps
    click
    oscpy
    psutil

    # sonic-pi runtime deps
    ruby
    erlang
    supercollider-with-sc3-plugins
    jack2
  ];

  dontUseSetuptoolsBuild = true;
  dontUsePipInstall = true;
  dontUseSetuptoolsCheck = true;

  installPhase = ''
    mkdir -p "$out/bin"
    cp sonic-pi-tool.py "$out/bin/sonic-pi-tool"
    chmod +x "$out/bin/sonic-pi-tool"

    substituteInPlace "$out/bin/sonic-pi-tool" --replace 'default_paths = (' 'default_paths = ('"'"'${sonic-pi}/app'"'"', '
  '';

  passthru.tests = {
    # test to make sure executable runs
    help = runCommand "${sonic-pi-tool.name}-help-test" {} ''
      ${sonic-pi-tool}/bin/sonic-pi-tool --help >$out
    '';
  };

  meta = with lib; {
    description = "Tool for interfacing with the Sonic Pi server from the command line";
    homepage = "https://github.com/emlyn/sonic-pi-tool";
    license = licenses.mpl20;
    platforms = [ "x86_64-linux" "i686-linux" "aarch64-linux" "armv7l-linux" ];
  };
}
; in sonic-pi-tool
