#!/usr/bin/env nix-shell
#!nix-shell update-shell.nix -i python3

# Derived from https://github.com/NixOS/nixpkgs under the following license:
#   Copyright (c) 2003-2021 Eelco Dolstra and the Nixpkgs/NixOS contributors
#
#   Permission is hereby granted, free of charge, to any person obtaining
#   a copy of this software and associated documentation files (the
#   "Software"), to deal in the Software without restriction, including
#   without limitation the rights to use, copy, modify, merge, publish,
#   distribute, sublicense, and/or sell copies of the Software, and to
#   permit persons to whom the Software is furnished to do so, subject to
#   the following conditions:
#
#   The above copyright notice and this permission notice shall be
#   included in all copies or substantial portions of the Software.
#
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
#   LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
#   OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
#   WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# format:
# $ nix run nixpkgs.python3Packages.black -c black update.py
# type-check:
# $ nix run nixpkgs.python3Packages.mypy -c mypy update.py
# linted:
# $ nix run nixpkgs.python3Packages.flake8 -c flake8 --ignore E501,E265,E402 update.py

# If you see `HTTP Error 429: too many requests` errors while running this script,
# refer to:
#
# https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/vim.section.md#updating-plugins-in-nixpkgs-updating-plugins-in-nixpkgs
#
# (or the equivalent file /doc/languages-frameworks/vim.section.md from Nixpkgs master tree).
#

import inspect
import os
import sys
import logging
import textwrap
from typing import List, Tuple
from pathlib import Path

log = logging.getLogger()

sh = logging.StreamHandler()
formatter = logging.Formatter('%(name)s:%(levelname)s: %(message)s')
sh.setFormatter(formatter)
log.addHandler(sh)

# Import plugin update library from scripts/pluginupdate.py
ROOT = Path(os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe()))))
sys.path.insert(0, os.path.join(ROOT.parent.parent, "scripts"))
import pluginupdate
from pluginupdate import run_nix_expr, PluginDesc

GET_PLUGINS = f"""(with import {ROOT.parent.parent} {{}};

with import (
    let
      lock = builtins.fromJSON (builtins.readFile {ROOT.parent.parent}/flake.lock);
    in fetchTarball {{
      url = "https://github.com/NixOS/nixpkgs/archive/${{lock.nodes.nixpkgs.locked.rev}}.tar.gz";
      sha256 = lock.nodes.nixpkgs.locked.narHash;
    }}
  )
  {{}};

let
  inherit (vimUtils.override {{inherit vim;}}) buildNeovimPluginFrom2Nix buildVimPluginFrom2Nix;
  generated = callPackage {ROOT}/generated.nix {{
    inherit buildNeovimPluginFrom2Nix buildVimPluginFrom2Nix;
  }};
  hasChecksum = value: lib.isAttrs value && lib.hasAttrByPath ["src" "outputHash"] value;
  getChecksum = name: value:
    if hasChecksum value then {{
      submodules = value.src.fetchSubmodules or false;
      sha256 = value.src.outputHash;
      rev = value.src.rev;
    }} else null;
  checksums = lib.mapAttrs getChecksum generated;
in lib.filterAttrs (n: v: v != null) checksums)"""

GET_PLUGINS_LUA = f"""
with import {ROOT.parent.parent} {{}};

with import (
    let
      lock = builtins.fromJSON (builtins.readFile {ROOT.parent.parent}/flake.lock);
    in fetchTarball {{
      url = "https://github.com/NixOS/nixpkgs/archive/${{lock.nodes.nixpkgs.locked.rev}}.tar.gz";
      sha256 = lock.nodes.nixpkgs.locked.narHash;
    }}
  )
  {{}};

lib.attrNames lua51Packages"""

HEADER = (
    "# This file has been generated by ./pkgs/vim-plugins/update.py. Do not edit!"
)

def isNeovimPlugin(plug: pluginupdate.Plugin) -> bool:
    '''
    Whether it's a neovim-only plugin
    We can check if it's available in lua packages
    '''
    global luaPlugins
    if plug.normalized_name in luaPlugins:
        log.debug("%s is a neovim plugin", plug)
        return True
    return False


class VimEditor(pluginupdate.Editor):
    def generate_nix(self, plugins: List[Tuple[PluginDesc, pluginupdate.Plugin]], outfile: str):
        sorted_plugins = sorted(plugins, key=lambda v: v[0].name.lower())

        with open(outfile, "w+") as f:
            f.write(HEADER)
            f.write(textwrap.dedent("""
                { lib, buildVimPluginFrom2Nix, buildNeovimPluginFrom2Nix, fetchFromGitHub, fetchgit }:

                final: prev:
                {
                """
            ))
            for pdesc, plugin in sorted_plugins:
                content = self.plugin2nix(pdesc, plugin)
                f.write(content)
            f.write("\n}\n")
        print(f"updated {outfile}")

    def plugin2nix(self, pdesc: PluginDesc, plugin: pluginupdate.Plugin) -> str:

        repo = pdesc.repo
        isNeovim = isNeovimPlugin(plugin)

        content = f"  {plugin.normalized_name} = "
        src_nix = repo.as_nix(plugin)
        content += """{buildFn} {{
    pname = "{plugin.name}";
    version = "{plugin.version}";
    src = {src_nix};
    meta.homepage = "{repo.uri}";
  }};

""".format(
        buildFn="buildNeovimPluginFrom2Nix" if isNeovim else "buildVimPluginFrom2Nix", plugin=plugin, src_nix=src_nix, repo=repo)
        print(content)
        return content

def main():

    global luaPlugins
    luaPlugins = run_nix_expr(GET_PLUGINS_LUA)

    editor = VimEditor("vim", ROOT, GET_PLUGINS)
    parser = editor.create_parser()
    args = parser.parse_args()
    pluginupdate.update_plugins(editor, args)


if __name__ == "__main__":
    main()
