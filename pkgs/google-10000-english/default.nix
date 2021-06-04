{ stdenvNoCC, lib, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "google-10000-english";
  version = "20190823";

  src = fetchFromGitHub {
    owner = "first20hours";
    repo = pname;
    #rev = "v${version}";
    rev = "5edad1bf213471d567a76414459afb97bfa85c68";
    sha256 = "1djsfgvmivqinw0f9vz4h428qqwg2flg5bhmh1jb83pa8f71smp0";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/dict
    cp google-10000-*.txt $out/share/dict
  '';

  meta = with lib; {
    description = "The 10,000 most common English words in order of frequency";
    homepage = "https://github.com/first20hours/google-10000-english";
    license = licenses.publicDomain;
  };
}
