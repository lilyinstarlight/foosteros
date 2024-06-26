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
      # hack to skip fetchGit when evaluating impurely and get original paths
      src = {
        outPath = ./.;
      };
    }
  ).defaultNix;
in

removeAttrs self.devShells.${system} [ "default" ]
