{ stdenv, lib, fetchFromGitHub, runCommand }:

let pridecat =
stdenv.mkDerivation rec {
  pname = "pridecat";
  version = "unstable-2020-06-19";

  src = fetchFromGitHub {
    owner = "lunasorcery";
    repo = pname;
    #rev = "v${version}";
    rev = "92396b11459e7a4b5e8ff511e99d18d7a1589c96";
    hash = "sha256-PyGLbbsh9lFXhzB1Xn8VQ9zilivycGFEIc7i8KXOxj8=";
  };

  strictDeps = true;

  patchPhase = ''
    sed -i -e 's#/usr/local#$(PREFIX)#g' Makefile
  '';

  dontConfigure = true;

  installPhase = ''
    mkdir -p $out/bin
    make PREFIX=$out install
  '';

  passthru.tests = {
    # test to make sure executable runs
    help = runCommand "${pridecat.name}-help-test" {} ''
      ${pridecat}/bin/pridecat --help >$out
    '';
  };

  meta = with lib; {
    homepage = "https://github.com/lunasorcery/pridecat";
    description = "Like cat but more colorful! ✨";
    license = licenses.cc-by-sa-40;
    maintainers = with maintainers; [ lilyinstarlight ];
    mainProgram = "pridecat";
  };
}
; in pridecat
