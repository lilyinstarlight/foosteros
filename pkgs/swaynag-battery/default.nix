{ stdenv, pkgs, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "swaynag-battery";
  version = "0.1.1.9999";

  goPackagePath = "github.com/m00qek/swaynag-battery";

  src = fetchFromGitHub {
    owner = "m00qek";
    repo = pname;
    #rev = "v${version}";
    rev = "396900b4282be190bb30f2527916ea29d44651bf";
    sha256 = "0bmw8yy8b5hw9c6kydznd8hig8l10d3gk6c5myah3zsf0d91ksxa";
  };
  vendorSha256 = "0kwzx3xf6j5z0zzmybxfpmnz8ll7jyh9fkrfjri7mlch77gn7ml7";

  patchPhase = ''
    sed -i -e 's#\(exec.Command("\)swaynag\("\)#\1${pkgs.sway}/bin/swaynag\2#g' swaynag.go
    sed -i -e 's#\(exec.Command("\)swaymsg\("\)#\1${pkgs.sway}/bin/swaymsg\2#g' swaymsg.go
  '';

  meta = with stdenv.lib; {
    homepage = "https://github.com/m00qek/swaynag-battery";
    description = "Show a message when battery is low and discharging";
    license = licenses.mit;
  };
}
