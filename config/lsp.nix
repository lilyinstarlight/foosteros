{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (python3.withPackages (ps: with ps; [ python-lsp-server pylsp-mypy ]))
    rust-analyzer rustc cargo clippy
    nil
    nodePackages.bash-language-server
  ];
}
