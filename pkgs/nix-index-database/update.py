#!/usr/bin/env nix-shell
#! nix-shell -i python3 -p

import json
import os.path
import subprocess
import urllib.request


version = sorted((release['tag_name'] for release in json.load(urllib.request.urlopen('https://api.github.com/repos/Mic92/nix-index-database/releases'))), key=lambda ver: int(ver.replace('-', '')))[-1]
narhash = json.loads(subprocess.run(
    ['nix', '--extra-experimental-features', 'nix-command', 'store', 'prefetch-file', '--json', f'https://github.com/Mic92/nix-index-database/releases/download/{version}/index-x86_64-linux'],
    capture_output=True, check=True).stdout)['hash']


pkg = f'''# This file has been generated by ./pkgs/nix-index-database/update.py. Do not edit!
{{ stdenvNoCC, lib, fetchurl }}:

stdenvNoCC.mkDerivation rec {{
  pname = "nix-index-database";
  version = "{version}";

  src = fetchurl {{
    url = "https://github.com/Mic92/nix-index-database/releases/download/${{version}}/index-x86_64-linux";
    sha256 = "{narhash}";
  }};

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp $src $out/files
  '';

  meta = with lib; {{
    description = "Weekly updated pre-built nix-index database";
    homepage = "https://github.com/Mic92/nix-index-database";
    license = licenses.publicDomain;
  }};
}}
'''

with open(os.path.join(os.path.dirname(__file__), 'default.nix'), 'w') as out:
    out.write(pkg)
