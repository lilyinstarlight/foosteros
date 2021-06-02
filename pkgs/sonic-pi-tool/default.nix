{ lib, buildPythonApplication, fetchFromGitHub, sonic-pi, click, oscpy, psutil, ruby, erlang, bash, supercollider, jack2 }:

buildPythonApplication rec {
  pname = "sonic-pi-tool";
  version = "0.0.0.9999";

  src = fetchFromGitHub {
    owner = "emlyn";
    repo = pname;
    #rev = "v${version}";
    rev = "05b77cc4b2201c8fed359c582dca138036042a08";
    sha256 = "0la8p35ckqg53406577fnf5zmfw25i05lwx1v4ragigw38pniw4h";
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
