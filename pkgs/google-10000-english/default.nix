{ lib
, stdenvNoCC
, fetchFromGitHub
, unstableGitUpdater
}:

stdenvNoCC.mkDerivation {
  pname = "google-10000-english";
  version = "0-unstable-2021-06-22";

  src = fetchFromGitHub {
    owner = "first20hours";
    repo = "google-10000-english";
    rev = "d0736d492489198e4f9d650c7ab4143bc14c1e9e";
    hash = "sha256-buSJiSOL/TRNq83XXJA1FxUXxsPnJQXkSeOMTTH2tIo=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/dict
    cp google-10000-*.txt $out/share/dict
  '';

  passthru.updateScript = unstableGitUpdater {};

  meta = with lib; {
    description = "The 10,000 most common English words in order of frequency";
    homepage = "https://github.com/first20hours/google-10000-english";
    license = licenses.publicDomain;
    maintainers = with maintainers; [ /*lilyinstarlight*/ ];
  };
}
