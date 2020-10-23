{ stdenv, pkgs, python3Packages, fetchpatch, fetchFromGitHub }:

python3Packages.buildPythonApplication rec {
  pname = "sonic-pi-tool";
  version = "8f03380";

  src = fetchFromGitHub {
    owner = "emlyn";
    repo = "sonic-pi-tool";
    rev = version;
    sha256 = "1cr17m88w1254fwfw50myppqkpw02q0ihy6lhjjz5kidjkgp06ba";
  };

  propagatedBuildInputs = with pkgs; [ sonic-pi python3Packages.click python3Packages.oscpy python3Packages.psutil ];
  dontUseSetuptoolsCheck = true;

  patches = [
    (fetchpatch {
      url = "https://github.com/lilyinstarlight/sonic-pi-tool.py/commit/23f6214fb7afaab392ed428648a4daa77eea90c0.patch";
      sha256 = "1npm6f1sk8nw48hlgbki5r086ppc470y9ywf2waja6pi3h6lk8q9";
    })
  ];

  installPhase = ''
    cp sonic-pi-tool.py $out/bin/sonic-pi-tool
    chmod +x $out/bin/sonic-pi-tool

    substituteInPlace $out/bin/sonic-pi-tool --replace 'default_paths = (' 'default_paths = ('"'"'${pkgs.sonic-pi}'"'"',\n'
  '';

  meta = with stdenv.lib; {
    description = "Tool for interfacing with the Sonic Pi server from the command line";
    homepage = "https://github.com/emlyn/sonic-pi-tool";
    license = licenses.mpl20;
  };

  passthru.shellPath = "/bin/sonic-pi-tool";
}
