{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    texlive.combined.scheme-full
    (pkgs.writeShellApplication {
      name = "pdflatexmk";
      runtimeInputs = with pkgs; [ texlive.combined.scheme-full ];
      text = ''
            latexmk -pdf "$@" && latexmk -c "$@"
      '';
    })
  ];
}
