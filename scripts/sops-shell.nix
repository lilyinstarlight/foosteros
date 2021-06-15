{ pkgs ? import <nixpkgs> {} }:

let
  sops-nix =
    let
      lock = builtins.fromJSON (builtins.readFile ../flake.lock);
    in fetchTarball {
      url = "https://github.com/Mic92/sops-nix/archive/${lock.nodes.sops-nix.locked.rev}.tar.gz";
      sha256 = lock.nodes.sops-nix.locked.narHash;
    };
in

with pkgs;

mkShell {
  sopsPGPKeyDirs = [
    "./keys/hosts"
    "./keys/users"
  ];
  nativeBuildInputs = [
    (pkgs.callPackage sops-nix {}).sops-pgp-hook
  ];
}
