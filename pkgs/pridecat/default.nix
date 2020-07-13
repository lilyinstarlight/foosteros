{ stdenv, pkgs, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "pridecat";
  version = "0.0.0.9999";

  src = fetchFromGitHub {
    owner = "lunasorcery";
    repo = pname;
    #rev = "v${version}";
    rev = "92396b11459e7a4b5e8ff511e99d18d7a1589c96";
    sha256 = "0gy6rsjz1qnf45262w7j5fbf5p232mzmwx9hhxbm3xi1pdnqn89z";
  };

  patchPhase = ''
    sed -i -e 's#/usr/local#$(PREFIX)#g' Makefile
  '';

  dontConfigure = true;

  installPhase = ''
    mkdir -p $out/bin
    make PREFIX=$out install
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/lunasorcery/pridecat";
    description = "Like cat but more colorful! ✨";
    license = licenses.cc-by-sa-40;
  };
}
