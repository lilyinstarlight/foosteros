{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    python3Packages.python-lsp-server
    rust-analyzer rustc cargo
    rnix-lsp
    nodePackages.bash-language-server
  ];
}
