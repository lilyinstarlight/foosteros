{ stdenv, pkgs, fetchzip }:

stdenv.mkDerivation rec {
  pname = "backgrounds";
  version = "20210525";

  src = fetchzip {
    url = "https://file.lily.flowers/foosteros/backgrounds/20210525.zip";
    stripRoot = false;
    sha256 = "x63gjzjn387wm9lgn7g7q7ibyvnc0ii3";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    cp -r * $out
  '';

  meta = with pkgs.lib; {
    description = "FoosterOS/2 backgrounds";
    homepage = "https://github.com/lilyinstarlight/foosteros";
  };
}
