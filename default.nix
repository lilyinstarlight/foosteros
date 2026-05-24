{ system ? builtins.currentSystem, ... }:

let
  self = (import (
      let
        lock = builtins.fromJSON (builtins.readFile ./flake.lock);
      in fetchTarball {
        url = "https://git.lix.systems/lix-project/flake-compat/archive/${lock.nodes.${lock.nodes.${lock.root}.inputs.flake-compat}.locked.rev}.tar.gz";
        sha256 = lock.nodes.${lock.nodes.${lock.root}.inputs.flake-compat}.locked.narHash;
      }
    )
    {
      src = ./.;
      copySourceTreeToStore = false;
    }
  ).defaultNix;
in

self.legacyPackages.${system} // self.packages.${system}
