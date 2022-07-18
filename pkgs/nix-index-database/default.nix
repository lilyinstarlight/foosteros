# This file has been generated by ./pkgs/nix-index-database/update.py. Do not edit!
{ stdenvNoCC, lib }:

stdenvNoCC.mkDerivation rec {
  pname = "nix-index-database";
  version = "2022-07-17";

  src = builtins.fetchurl {
    url = "https://github.com/Mic92/nix-index-database/releases/download/${version}/index-x86_64-linux";
    sha256 = "sha256-wCOH0w6Ximm8YFw4Xd/8w6QA3WmWbwz8xSOndBS7SMU=";
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
