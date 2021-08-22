{ lib, stdenv, fetchFromGitHub, cmake, static ? stdenv.hostPlatform.isStatic }:

stdenv.mkDerivation rec {
  pname = "platform-folders";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "sago007";
    repo = "PlatformFolders";
    rev = version;
    sha256 = "098vzw5a6wmxi0mf0flb3m0p0mijq38k87xj2sm0j1w4lvimha8i";
  };

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=${if static then "OFF" else "ON"}"
  ];

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "A C++ library to look for standard platform directories so that you do not need to write platform-specific code";
    homepage = "https://github.com/sago007/PlatformFolders";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
