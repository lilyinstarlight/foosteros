{ pkgs, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonApplication rec {
  pname = "sonic-pi-tool";
  version = "0.0.0.9999";

  src = fetchFromGitHub {
    owner = "emlyn";
    repo = pname;
    #rev = "v${version}";
    rev = "05b77cc4b2201c8fed359c582dca138036042a08";
    sha256 = "0la8p35ckqg53406577fnf5zmfw25i05lwx1v4ragigw38pniw4h";
  };

  propagatedBuildInputs = with pkgs; [ sonic-pi python3Packages.click python3Packages.oscpy python3Packages.psutil ];

  dontUseSetuptoolsBuild = true;
  dontUsePipInstall = true;
  dontUseSetuptoolsCheck = true;

  installPhase = ''
    mkdir -p "$out/bin"
    cp sonic-pi-tool.py "$out/bin/sonic-pi-tool"
    chmod +x "$out/bin/sonic-pi-tool"

    substituteInPlace "$out/bin/sonic-pi-tool" --replace 'default_paths = (' 'default_paths = ('"'"'${pkgs.sonic-pi}/app'"'"', '

    wrapProgram "$out/bin/sonic-pi-tool" \
      --prefix PATH : ${pkgs.ruby}/bin:${pkgs.bash}/bin:${pkgs.supercollider}/bin:${pkgs.jack2Full}/bin \
      --set AUBIO_LIB "${pkgs.aubio}/lib/libaubio.so"
  '';

  meta = with pkgs.lib; {
    description = "Tool for interfacing with the Sonic Pi server from the command line";
    homepage = "https://github.com/emlyn/sonic-pi-tool";
    license = licenses.mpl20;
  };

  passthru.shellPath = "/bin/sonic-pi-tool";
}
