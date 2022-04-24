{ lib, stdenv, fetchFromGitHub, python3, cmake, libglvnd, libGLU }:

stdenv.mkDerivation rec {
  pname = "gl3w";
  version = "2021-07-16";

  src = fetchFromGitHub {
    owner = "skaslev";
    repo = pname;
    rev = "3755745085ac2e865fd22270cfe9169c26640f70";
    hash = "sha256-d6wFrHJNmu2qFXeBN/+WZAOPW76mZuy/xw21486qhC0=";
  };

  nativeBuildInputs = [ python3 cmake ];
  propagatedBuildInputs = [ libglvnd.dev libGLU.dev ];

  dontUseCmakeBuildDir = true;

  # These files must be copied rather than linked since they are considered
  # outputs for the custom command, and CMake expects to be able to touch them
  preConfigure = ''
    mkdir -p include/{GL,KHR}
    cp ${libglvnd.dev}/include/GL/glcorearb.h include/GL/glcorearb.h
    cp ${libglvnd.dev}/include/KHR/khrplatform.h include/KHR/khrplatform.h
  '';

  meta = with lib; {
    description = "Simple OpenGL core profile loading";
    homepage = "https://github.com/skaslev/gl3w";
    license = licenses.unlicense;
    maintainers = with maintainers; [ lilyinstarlight ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
