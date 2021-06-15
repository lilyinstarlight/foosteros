{ lib, buildGoModule, fetchFromGitHub, makeWrapper, sway }:

buildGoModule rec {
  pname = "swaynag-battery";
  version = "unstable-2020-05-25";

  src = fetchFromGitHub {
    owner = "m00qek";
    repo = pname;
    #rev = "v${version}";
    rev = "396900b4282be190bb30f2527916ea29d44651bf";
    sha256 = "0bmw8yy8b5hw9c6kydznd8hig8l10d3gk6c5myah3zsf0d91ksxa";
  };
  vendorSha256 = "0kwzx3xf6j5z0zzmybxfpmnz8ll7jyh9fkrfjri7mlch77gn7ml7";

  nativeBuildInputs = [
    makeWrapper
  ];

  patchPhase = ''
    substituteInPlace parameters.go \
      --replace 'message:   "You battery is running low. Please plug in a power adapter"' 'message:   "Your battery is running low. Please plug in a power adapter"'
  '';

  fixupPhase = ''
    wrapProgram $out/bin/swaynag-battery \
      --prefix PATH : "${sway}/bin"
  '';

  meta = with lib; {
    homepage = "https://github.com/m00qek/swaynag-battery";
    description = "Show a message when battery is low and discharging";
    license = licenses.mit;
  };
}
