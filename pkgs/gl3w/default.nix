{ lib, stdenv, fetchFromGitHub, python3, cmake, libglvnd, libGLU }:

stdenv.mkDerivation rec {
  pname = "gl3w";
  version = "2021-07-16";

  src = fetchFromGitHub {
    owner = "skaslev";
    repo = pname;
    rev = "3755745085ac2e865fd22270cfe9169c26640f70";
    sha256 = "0bc4mb7f7d8dqyzyqrm6prdqy0v4jvzkg0bp2nmfv6jdfan0bb3p";
  };

  nativeBuildInputs = [ python3 cmake ];
  propagatedBuildInputs = [ libglvnd.dev libGLU.dev ];

  dontUseCmakeBuildDir = true;

  preConfigure = ''
    mkdir -p include/{GL,KHR}
    cp ${libglvnd.dev}/include/GL/glcorearb.h include/GL/glcorearb.h
    cp ${libglvnd.dev}/include/KHR/khrplatform.h include/KHR/khrplatform.h
  '';

  meta = with lib; {
    description = "Simple OpenGL core profile loading";
    homepage = "https://github.com/skaslev/gl3w";
    license = licenses.unlicense;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
