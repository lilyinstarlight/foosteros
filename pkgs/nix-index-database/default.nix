# This file has been generated by ./pkgs/nix-index-database/update.py. Do not edit!
{ stdenvNoCC, lib }:

stdenvNoCC.mkDerivation rec {
  pname = "nix-index-database";
  version = "2022-05-15";

  src = builtins.fetchurl {
    url = "https://github.com/Mic92/nix-index-database/releases/download/${version}/index-x86_64-linux";
    hash = "sha256-1jAMN2ih53NKoMhb161owzDyi1pJ3lNNW4qKlP0K90w=";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp $src $out/files
  '';

  meta = with lib; {
    description = "Weekly updated pre-built nix-index database";
    homepage = "https://github.com/Mic92/nix-index-database";
    license = licenses.publicDomain;
    maintainers = with maintainers; [ lilyinstarlight ];
  };
}
