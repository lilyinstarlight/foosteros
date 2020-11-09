{ stdenv, pkgs, python3Packages, fetchpatch, fetchFromGitHub }:

python3Packages.buildPythonApplication rec {
  pname = "sonic-pi-tool";
  version = "0.0.0.9999";

  src = fetchFromGitHub {
    owner = "emlyn";
    repo = pname;
    #rev = "v${version}";
    rev = "8f03380495ab3449cd6abaf9d8659e63818dc58a";
    sha256 = "01xsdhg6jqk5bavcb83mbf7fcpaq3g8pqmfvnqwn7ypv67zwihgd";
  };

  propagatedBuildInputs = with pkgs; [ sonic-pi python3Packages.click python3Packages.oscpy python3Packages.psutil ];

  dontUseSetuptoolsBuild = true;
  dontUsePipInstall = true;
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
