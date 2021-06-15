{ lib, buildPythonApplication, fetchFromGitHub, sonic-pi, click, oscpy, psutil, ruby, erlang, bash, supercollider, jack2 }:

buildPythonApplication rec {
  pname = "sonic-pi-tool";
  version = "unstable-2021-03-07";

  src = fetchFromGitHub {
    owner = "emlyn";
    repo = pname;
    #rev = "v${version}";
    rev = "b955369294b7669b2706b26d388ec2c2a9d0d3a2";
    sha256 = "06y8a6fjhc5yi1db687wsi8qn4jd9kqvzq1lv4p4rlg6d1j540hy";
  };

  propagatedBuildInputs = [ sonic-pi click oscpy psutil ];

  dontUseSetuptoolsBuild = true;
  dontUsePipInstall = true;
  dontUseSetuptoolsCheck = true;

  installPhase = ''
    mkdir -p "$out/bin"
    cp sonic-pi-tool.py "$out/bin/sonic-pi-tool"
    chmod +x "$out/bin/sonic-pi-tool"

    substituteInPlace "$out/bin/sonic-pi-tool" --replace 'default_paths = (' 'default_paths = ('"'"'${sonic-pi}/app'"'"', '

    wrapProgram "$out/bin/sonic-pi-tool" \
      --prefix PATH : ${ruby}/bin:${erlang}/bin:${bash}/bin:${supercollider}/bin:${jack2}/bin
  '';

  meta = with lib; {
    description = "Tool for interfacing with the Sonic Pi server from the command line";
    homepage = "https://github.com/emlyn/sonic-pi-tool";
    license = licenses.mpl20;
  };
}
