{ ... }@args:

let
  self = (import (
      let
        lock = builtins.fromJSON (builtins.readFile ../flake.lock);
      in fetchTarball {
        url = "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
        sha256 = lock.nodes.flake-compat.locked.narHash;
      }
    )
    {
      # hack to skip fetchGit when evaluating impurely and get original paths
      src = {
        outPath = ../.;
      };
    }
  ).defaultNix;
in

import "${self.inputs.nixpkgs}/maintainers/scripts/update.nix" ({
  predicate = _path: pkg: with self.inputs.nixpkgs.lib;
    hasPrefix (toString ../.) (head (splitString ":" pkg.meta.position or ""));
  include-overlays = builtins.attrValues (removeAttrs self.overlays [ "default" ]);
} // args)
