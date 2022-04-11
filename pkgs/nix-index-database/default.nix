# This file has been generated by ./pkgs/nix-index-database/update.py. Do not edit!
{ stdenvNoCC, lib, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "nix-index-database";
  version = "2022-04-10";

  src = fetchurl {
    url = "https://github.com/Mic92/nix-index-database/releases/download/${version}/index-x86_64-linux";
    hash = "sha256-lXdMSpd0Q2e0OLeeSXtICxf428CqVVEj0876LSSK0CI=";
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
  };
}
