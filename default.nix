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
      # hack to skip fetchGit when evaluating impurely and get original paths
      src = {
        outPath = ./.;
      };
    }
  ).defaultNix;
in

self.legacyPackages.${system} // self.packages.${system}
