{ system ? builtins.currentSystem, ... }:

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
      src =  ../.;
    }
  ).defaultNix;
in

with self.inputs.nixpkgs.legacyPackages.${system};

mkShell {
  sopsPGPKeyDirs = [
    ../keys/hosts
    ../keys/users
  ];
  nativeBuildInputs = [
    self.inputs.sops-nix.packages.${system}.sops-import-keys-hook
  ];
}
