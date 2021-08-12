{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    python3Packages.python-lsp-server rust-analyzer rnix-lsp nodePackages.bash-language-server
  ];
}
