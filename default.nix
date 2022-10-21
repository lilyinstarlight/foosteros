{ system ? builtins.currentSystem, ... }:

let
  self = (import (
      let
        lock = builtins.fromJSON (builtins.readFile ./flake.lock);
      in fetchTarball {
        url = "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
        sha256 = lock.nodes.flake-compat.locked.narHash;
      }
    )
    {
      # hack to prevent flake-compat from using fetchGit with impure entrypoint
      # needed for stuff like scripts/update.nix to properly find packages
      src =  { outPath = ./.; };
    }
  ).defaultNix;
in

self.legacyPackages.${system} // self.packages.${system} // { lib = self.inputs.nixpkgs.legacyPackages.${system}.lib // self.lib; }
