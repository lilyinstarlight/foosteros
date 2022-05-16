#!/usr/bin/env nix-shell
#! nix-shell -i python3 -p

import json
import os
import os.path
import subprocess
import urllib.request


api_headers = {'Authorization': f'token {os.environ["GITHUB_TOKEN"]}'} if 'GITHUB_TOKEN' in os.environ else {}

version = json.load(urllib.request.urlopen(
    urllib.request.Request('https://api.github.com/repos/Mic92/nix-index-database/releases/latest', headers=api_headers)))['tag_name']
narhash = json.loads(subprocess.run(
    ['nix', '--extra-experimental-features', 'nix-command', 'store', 'prefetch-file', '--json', f'https://github.com/Mic92/nix-index-database/releases/download/{version}/index-x86_64-linux'],
    capture_output=True, check=True).stdout)['hash']


pkg = f'''# This file has been generated by ./pkgs/nix-index-database/update.py. Do not edit!
{{ stdenvNoCC, lib }}:

stdenvNoCC.mkDerivation rec {{
  pname = "nix-index-database";
  version = "{version}";

  src = builtins.fetchurl {{
    url = "https://github.com/Mic92/nix-index-database/releases/download/${{version}}/index-x86_64-linux";
    hash = "{narhash}";
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
    maintainers = with maintainers; [ lilyinstarlight ];
  }};
}}
'''

with open(os.path.join(os.path.dirname(__file__), 'default.nix'), 'w') as out:
    out.write(pkg)
