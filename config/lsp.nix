{ config, lib, pkgs, ... }:

lib.mkIf config.foosteros.profiles.lsp {
  environment.systemPackages = with pkgs; let
    # TODO: re-enable pylsp-mypy when NixOS/nixpkgs#541116 is merged or build otherwise fixed
    #pylsp-env = python3.withPackages (ps: with ps; [ python-lsp-server pylsp-mypy ]);
    pylsp-env = python3.withPackages (ps: with ps; [ python-lsp-server ]);
    pylsp-with-plugins = runCommand "pylsp" {} ''
      mkdir -p $out/bin
      ln -s ${pylsp-env}/bin/pylsp $out/bin/pylsp
    '';
  in [
    pylsp-with-plugins
    rust-analyzer rustc rustfmt cargo clippy
    nil # TODO: consider nixd
    bash-language-server
  ];
}
