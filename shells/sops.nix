with import <nixpkgs> {};
mkShell {
  sopsPGPKeyDirs = [
    "./keys/hosts"
    "./keys/users"
  ];
  nativeBuildInputs = [
    (pkgs.callPackage <sops-nix> {}).sops-pgp-hook
  ];
}
