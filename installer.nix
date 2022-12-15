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
      src = ./.;
    }
  ).defaultNix;
in

with self.inputs.nixpkgs.legacyPackages.${system};

symlinkJoin {
  name = "foosteros-installers";
  paths = map (cfg: "${cfg.config.system.build.installer}/iso") (lib.filter (cfg: cfg.pkgs.stdenv.hostPlatform.system == stdenv.hostPlatform.system && cfg.config.system.build ? installer) (lib.attrValues self.nixosConfigurations));
}
