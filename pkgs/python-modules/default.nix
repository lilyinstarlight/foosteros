{ python3Packages }:

# TODO: remove this whole directory when NixOS/nixpkgs#183862 is merged
rec {
  whatthepatch = python3Packages.callPackage ./whatthepatch {};
  python-lsp-server = python3Packages.callPackage ./python-lsp-server {
    inherit whatthepatch;
  };
}
